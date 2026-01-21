# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Installation

Assuming you're using Debian/Ubuntu:

    sudo apt install yadm
    yadm clone git@github.com:spacebarlabs/dotfiles.git
    # OR
    # yadm clone https://github.com/spacebarlabs/dotfiles.git
    yadm submodule update --init --recursive

#### Post install

In `vim`, run `:PlugInstall` to install all Vim plugins

### Updating

    yadm pull
    yadm submodule update --init --recursive
