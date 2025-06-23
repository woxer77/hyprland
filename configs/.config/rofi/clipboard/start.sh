#!/usr/bin/env bash

dir="$HOME/.config/rofi/clipboard"
theme='clipboard'

## Run 
cliphist list | head -n 20 | \
rofi -dmenu -display-columns 2 -theme ${dir}/${theme}.rasi | \
cliphist decode | wl-copy
