export EDITOR=vim
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh-custom
export ZSH_THEME="continuity"
plugins=(git git-flow rails ruby macos gem vi-mode bundler)

source $ZSH/oh-my-zsh.sh

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
# Add the following to your ~/.bashrc or ~/.zshrc
alias vi='vim'

PATH=$PATH:$HOME/bin # Make personal scripts available
PATH=$PATH:$HOME/.bin # Make dotfiles scripts available

# tell nokogiri to use sysem libraries instead of compiling packaged libs
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# Prevent warnings if the user has not set up a tmux user.conf file
if [ ! -f "$HOME/.tmux/user.conf" ]; then
  touch $HOME/.tmux/user.conf
fi

eval "$(~/.local/bin/mise activate zsh)"
