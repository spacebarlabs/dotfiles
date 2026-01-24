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

# --- Custom Keybindings ---
# Bind Ctrl+e to accept autosuggestions
bindkey '^e' autosuggest-accept

# Ensure this works in vi-mode 'Insert' mode
bindkey -M viins '^e' autosuggest-accept

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

PATH=$HOME/.bin:$PATH:$HOME/bin # Make personal scripts available

export CDPATH="$CDPATH:$HOME/git"

# tell nokogiri to use sysem libraries instead of compiling packaged libs
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# Prevent warnings if the user has not set up a tmux user.conf file
if [ ! -f "$HOME/.tmux/user.conf" ]; then
  touch "$HOME/.tmux/user.conf"
fi

eval "$(mise activate zsh)"

# Check if Git Maintenance failed recently
if systemctl --user --quiet is-failed git-maintenance@hourly.service; then
    echo -e "\033[0;31m[WARNING] Git background maintenance is failing!\033[0m"
    echo "Run this to debug:"
    echo "  journalctl --user -u git-maintenance@hourly.service -n 20"
    echo "Or restart maintenance with:"
    echo "  git-maintenance-restart"
    echo ""
fi
