#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cls='clear'
alias img='loupe'

mem() {
  if [ -z "$1" ]; then
    echo "Usage: mem <process_name>"
    return 1
  fi
  echo "Running: smem -c 'pss command' | grep -i -- \"$1\" | awk '{sum+=\$1} END {printf \"%.2f MB\\n\", sum/1024}'"
  smem -c "pss command" | grep -i -- "$1" | awk '{sum+=$1} END {printf "%.2f MB\n", sum/1024}'
}

eval "$(starship init bash)"

# Created by `pipx` on 2025-05-23 16:30:18
export PATH="$PATH:/home/woxer/.local/bin"

export PATH=$PATH:/home/woxer/.spicetify
