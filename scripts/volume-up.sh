#!/bin/bash

LOCKFILE="/tmp/volume-lock"

[ -f "$LOCKFILE" ] && exit 0
touch "$LOCKFILE"

MAX_VOLUME=150
CURR_VOLUME=$(pamixer --get-volume)
STEP=5
IS_MUTED=$(pamixer --get-volume-human)

if [ "$CURR_VOLUME" -lt "$MAX_VOLUME" ]; then
  pamixer --allow-boost -i "$STEP"
fi

if [ "$IS_MUTED" = "muted" ]; then
  pamixer -t
  if [ "$CURR_VOLUME" -eq 0 ]; then
    pamixer --set-volume "$STEP"
  fi
fi

# Удалить lock-файл
rm -f "$LOCKFILE"
