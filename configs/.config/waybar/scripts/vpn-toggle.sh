#!/bin/bash

CONFIG_PATH="/home/woxer/.config/wireguard/wg-client.conf"
WG_INTERFACE=$(basename "$CONFIG_PATH" .conf)

if ip link show "$WG_INTERFACE" &> /dev/null; then
    sudo /usr/bin/wg-quick down "$CONFIG_PATH"
else
    sudo /usr/bin/wg-quick up "$CONFIG_PATH"
fi

pkill -RTMIN+10 waybar # for insta module update
