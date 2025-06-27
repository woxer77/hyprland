#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$PATH:/home/woxer/.local/bin"
export NNN_PLUG='j:jump;p:preview-tui'
export NNN_OPENER="$HOME/.config/nnn/plugins/nuke"
export NNN_FIFO=/tmp/nnn.fifo
export NNN_SPLIT="v"

eval "$(starship init bash)"
eval "$(zoxide init bash)"

alias ls='ls --color=auto'
#alias ls='n'
alias grep='grep --color=auto'
alias cls='clear'
alias img='loupe'
alias j='z'

mem() {
  if [ -z "$1" ]; then
    echo "Usage: mem <process_name>"
    return 1
  fi
  echo "Running: smem -c 'pss command' | grep -i -- \"$1\" | awk '{sum+=\$1} END {printf \"%.2f MB\\n\", sum/1024}'"
  smem -c "pss command" | grep -i -- "$1" | awk '{sum+=$1} END {printf "%.2f MB\n", sum/1024}'
}

n ()
{
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    command nnn -P p "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" > /dev/null
    }
}


