# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Installation

Assuming you're using Debian/Ubuntu:

    sudo apt install yadm
    yadm clone --recurse-submodules git@github.com:spacebarlabs/dotfiles.git
    # OR
    # yadm clone --recurse-submodules https://github.com/spacebarlabs/dotfiles.git

#### Post install

In `vim`, run `:PlugInstall` to install all Vim plugins

### Updating

    yadm pull
    yadm submodule update --remote
