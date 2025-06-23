#!/bin/bash

LOCKFILE="/tmp/volume-lock"

[ -f "$LOCKFILE" ] && exit 0
touch "$LOCKFILE"

CURR_VOLUME=$(pamixer --get-volume)
STEP=5

if [ "$CURR_VOLUME" = "$STEP" ]; then
  pamixer -t
  pamixer --set-volume 0
else
  pamixer --allow-boost -d "$STEP"
fi

# Удаляем lock-файл
rm -f "$LOCKFILE"
