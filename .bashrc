# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

###########
#         #
# vi mode #
#         #
###########

# ## Environment Variables
#
# ### See Also
#
# * [VISUAL vs EDITOR what's the difference?](http://unix.stackexchange.com/questions/4859/visual-vs-editor-whats-the-difference)

export EDITOR="vim"
export PAGER="less"
export VISUAL="vim"

# ## Bindings

# Only bind with interactive shells, otherwise will get:
#
#     bind: warning: line editing not enabled
case "$-" in
*i*)
  # TODO: Maybe to `bind -f /etc/inputrc` too

  # Allow a key-press to clear the screen.
  # Typically, this is ^L in emacs mode.
  #
  # FIXME: This doesn't seem to work in GNU screen, but works elsewhere.
  bind -x '"\C-l":clear'
esac

# ## Aliases
#
# Add vi input to progams that don't use GNU readline.
#
# ### Dependencies
#
# * Ubuntu: `sudo apt-get install rlwrap`
#
# ### See Also
#
# * http://nodejs.org/docs/v0.4.7/api/repl.html

# FIXME: Tab completion doesn't work
if command -v rlwrap >/dev/null 2>&1; then
  alias node="env NODE_NO_READLINE=1 rlwrap node"
fi

bind "set completion-ignore-case on"

# Add .bin directory to PATH for custom executables
export PATH="$HOME/.bin:$PATH"

# An alternative to chsh
#
# Switch to zsh if it is installed and we are in an interactive shell
if [ -t 1 ] && command -v zsh >/dev/null; then
  exec zsh
fi
