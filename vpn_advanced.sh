#!/bin/bash

# Get current status of a VPN connection with options to connect/disconnect.
# Forked from https://git.io/Jkefu and modified for Cisco AnyConnect VPN

# <bitbar.title>VPN Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Jesse Jarzynka</bitbar.author>
# <bitbar.author.github>jessejoe</bitbar.author.github>
# <bitbar.desc>Displays status of a VPN interface with option to connect/disconnect.</bitbar.desc>
# <bitbar.image>http://i.imgur.com/RkmptwO.png</bitbar.image>

VPN_EXECUTABLE=/opt/cisco/anyconnect/bin/vpn
VPN_HOST="TS-CORP"
VPN_INTERFACE="utun2"
VPN_USERNAME="amardeep.kahali"
# A command that will result in your VPN password. Recommend using
# "security find-generic-password -g -a foo" where foo is an account
# in your OSX Keychain, to avoid passwords stored in plain text
GET_VPN_PASSWORD="/usr/bin/security find-generic-password -wl 'vpn_automator'"
# Command to determine if VPN is connected or disconnected
VPN_CONNECTED="/sbin/ifconfig | egrep -A1 $VPN_INTERFACE | grep inet"
# Command to run to disconnect VPN
VPN_DISCONNECT_CMD="/opt/cisco/anyconnect/bin/vpn disconnect"

case "$1" in
    connect)
        VPN_PASSWORD=$(eval "$GET_VPN_PASSWORD")
        # VPN connection command, should eventually result in $VPN_CONNECTED,
        # may need to be modified for VPN clients other than openconnect
        printf "${VPN_USERNAME}\n${VPN_PASSWORD}\ny" | "$VPN_EXECUTABLE" -s connect "$VPN_HOST" &> /dev/null &
        # Wait for connection so menu item refreshes instantly
        until eval "$VPN_CONNECTED"; do sleep 1; done
        ;;
    disconnect)
        eval "$VPN_DISCONNECT_CMD"
        # Wait for disconnection so menu item refreshes instantly
        until [ -z "$(eval "$VPN_CONNECTED")" ]; do sleep 1; done
        ;;
esac

if [ -n "$(eval "$VPN_CONNECTED")" ]; then
    echo "▲ | color=green"
    echo '---'
    echo "Disconnect VPN | bash='$0' param1=disconnect terminal=false refresh=true"
    exit
else
    echo "▼ | color=red"
    echo '---'
    echo "Connect VPN | bash='$0' param1=connect terminal=false refresh=true"
    exit
fi
