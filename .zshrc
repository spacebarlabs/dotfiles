export EDITOR=vim
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh-custom
export ZSH_THEME="spacebarlabs"
plugins=(git rails ruby gem vi-mode bundler)

source "$ZSH/oh-my-zsh.sh"

export LC_ALL=en_US.UTF-8

#disable ctrl-s/suspension
stty stop undef
setopt NO_FLOW_CONTROL
setopt magicequalsubst
setopt interactivecomments
bindkey '^R' history-incremental-search-backward
autoload -U zrecompile

#ignore obnoxious stuff
alias git='nocorrect noglob git'
alias rake='noglob rake'

alias vi='vim'
alias gti=git
alias tig=git
alias igt=git
alias tit=git

alias norg="gron --ungron"
alias ungron="gron --ungron"

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

PATH=$PATH:$HOME/bin # Make personal scripts available

export CDPATH="$CDPATH:$HOME/git"

# tell nokogiri to use sysem libraries instead of compiling packaged libs
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# Prevent warnings if the user has not set up a tmux user.conf file
if [ ! -f "$HOME/.tmux/user.conf" ]; then
  touch "$HOME/.tmux/user.conf"
fi

eval "$(~/.local/bin/mise activate zsh)"

# Case insensitive completion (m:{a-z}={A-Z} matches lowercase to uppercase)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
