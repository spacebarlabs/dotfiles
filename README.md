# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Installation

Assuming you're using Debian/Ubuntu:

    # Download and review the installation script before running
    curl -L -o /tmp/oh-my-zsh-install.sh https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
    # Review the script: less /tmp/oh-my-zsh-install.sh
    sh /tmp/oh-my-zsh-install.sh
    sudo apt install yadm
    yadm clone git@github.com:spacebarlabs/dotfiles.git
    # OR
    # yadm clone https://github.com/spacebarlabs/dotfiles.git

#### Post install

In `vim`, run `:PlugInstall` to install all Vim plugins

### Updating

    yadm pull
