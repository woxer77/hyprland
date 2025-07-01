#!/bin/bash

VPN_INTERFACE="tun0"

if ip link show "$VPN_INTERFACE" &> /dev/null; then
    echo '{"text": "VPN", "class": "connected", "tooltip": "OpenVPN is active"}'
else
    echo '{"text": "VPN", "class": "disconnected", "tooltip": "OpenVPN is inactive"}'
fi
