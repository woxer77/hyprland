#!/bin/bash

CONFIG_PATH="/home/woxer/.config/wireguard/wg0.conf"
WG_INTERFACE=$(basename "$CONFIG_PATH" .conf)

if ip link show "$WG_INTERFACE" &> /dev/null; then
    echo '{"text": "VPN", "class": "connected", "tooltip": "WireGuard VPN is active"}'
else
    echo '{"text": "VPN", "class": "disconnected", "tooltip": "WireGuard VPN is inactive"}'
fi
