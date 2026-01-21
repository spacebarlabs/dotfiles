# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Installation

Assuming you're using Debian/Ubuntu:

    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    sudo apt install yadm
    yadm clone --recurse-submodules git@github.com:spacebarlabs/dotfiles.git
    # OR
    # yadm clone --recurse-submodules https://github.com/spacebarlabs/dotfiles.git

#### Post install

Vim plugins are managed as git submodules and will be automatically loaded from `.vim/pack/plugins/start/`.
If you cloned without `--recurse-submodules`, run:

    yadm submodule update --init --recursive

### Updating

    yadm pull
