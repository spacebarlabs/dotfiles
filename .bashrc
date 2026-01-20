# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

source "$HOME/.vi-everywhere/bash.d/init.sh"

bind "set completion-ignore-case on"
