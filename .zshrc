export EDITOR=vim
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh-custom
export ZSH_THEME="spacebarlabs"
plugins=(git rails ruby gem vi-mode bundler $ZSH_CUSTOM/plugins/*(N:t))
zstyle ':omz:update' mode disabled

source "$ZSH/oh-my-zsh.sh"

export LC_ALL=en_US.UTF-8

#disable ctrl-s/suspension
stty stop undef
setopt NO_FLOW_CONTROL
setopt magicequalsubst
setopt interactivecomments
bindkey '^R' history-incremental-search-backward
autoload -U zrecompile

# --- Completion System Configuration ---

autoload -U zrecompile

# This allows 'cd doc' -> 'Documents' and 'cd xml' -> 'Project.XML'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Enables arrow-key navigation through the completion list
zstyle ':completion:*' menu select

# Adds clear headers and colors to completion lists
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# Uses 'ls' colors for the completion menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Always show directories first, then files
zstyle ':completion:*' group-order 'directories' 'files'

# Automatically find new executables (rehash) immediately after installation
zstyle ':completion:*' rehash true

# Restore Emacs-style end-of-line behavior for Ctrl+e
bindkey '^e' end-of-line
bindkey -M viins '^e' end-of-line

# Bind Alt+Enter to accept and execute the suggestion immediately
bindkey '^[^M' autosuggest-execute

# Ensure this works in vi-mode 'Insert' mode
bindkey -M viins '^[^M' autosuggest-execute

# --- Aliases ---

# 'nocorrect' to stop zsh from second-guessing git commands
alias git='nocorrect noglob git'
alias rake='noglob rake'

alias vi='vim'
alias gti=git
alias tig=git
alias igt=git
alias tit=git

alias norg="gron --ungron"
alias ungron="gron --ungron"

alias fd=fdfind

# From a PeepCode video
take() {
  mkdir -p "$1"
  cd "$1" || return
}

# No more cd ../../../.. but up 4
# From http://serverfault.com/a/28649/22593
up() {
  local d=""
  local limit="$1"
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo "$d" | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd "$d" || return
}

# cd to git root
git-cd() {
  # 1. Get the root directory
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)

  # 2. Check if we are actually in a git repo
  if [[ -n "$root" ]]; then
    cd "$root"
  else
    echo "Error: Not currently in a git repository."
    return 1
  fi
}

PATH=$HOME/.local/bin:$PATH:$HOME/bin # Make personal scripts available

export CDPATH="$CDPATH:$HOME/git"

# tell nokogiri to use sysem libraries instead of compiling packaged libs
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# Prevent warnings if the user has not set up a tmux user.conf file
if [ ! -f "$HOME/.tmux/user.conf" ]; then
  touch "$HOME/.tmux/user.conf"
fi

# Activate mise only if it's installed
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Check if Git Maintenance failed recently (only if systemd is available)
if command -v systemctl &> /dev/null; then
    if systemctl --user --quiet is-failed git-maintenance@hourly.service; then
        echo -e "\033[0;31m[WARNING] Git background maintenance is failing!\033[0m"
        echo "Run this to debug:"
        echo "  journalctl --user -u git-maintenance@hourly.service -n 20"
        echo "Check for common issues:"
        echo "  git-maintenance-check"
        echo "Restart maintenance with:"
        echo "  git-maintenance-restart"
        echo ""
    fi
fi

# --- Notification & Silence Modifications ---

# Disable the standard "error" beep (e.g., tab completion fails or backspace at start of line)
unsetopt beep

# Notification Wrapper for long-running commands
preexec() {
  cmd_start_time=$SECONDS
  cmd_full_name="$1"
  # Capture the first word of the command to check for exit/logout
  cmd_basename="${1%% *}"
}

precmd() {
  if [ -n "$cmd_start_time" ]; then
    local duration=$((SECONDS - cmd_start_time))

    # Notify only if:
    # 1. The command took 60 seconds or longer
    # 2. The command was NOT 'exit' or 'logout'
    if [ $duration -ge 60 ] && [[ "$cmd_basename" != "exit" ]] && [[ "$cmd_basename" != "logout" ]]; then

      # Define the specific 3-bell pattern with 0.1s delays
      ring_bell() {
        echo -ne "\a"
        sleep 0.1
        echo -ne "\a"
        sleep 0.1
        echo -ne "\a"
      }

      # Determine notification method based on connection type
      if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" ]]; then
        # REMOTE (SSH): Use the audible/visual bell
        ring_bell
      else
        # LOCAL (Ubuntu Desktop): Try visual notification first
        if command -v notify-send >/dev/null; then
          notify-send "Task Finished (${duration}s)" "$cmd_full_name"
        else
          # Fallback to bell if notify-send is unavailable locally
          ring_bell
        fi
      fi
    fi
    # Reset variables for the next command
    unset cmd_start_time
    unset cmd_basename
    unset cmd_full_name
  fi
}
