#!/bin/bash

VPN_INTERFACE="tun0"
CONFIG_PATH="$HOME/.config/openvpn/openvpn.ovpn"

if ip link show "$VPN_INTERFACE" &> /dev/null; then
    sudo killall openvpn
else
    sudo openvpn --config "$CONFIG_PATH" --daemon
fi

pkill -RTMIN+10 waybar # for insta module update
