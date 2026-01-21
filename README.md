# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Installation

See also: https://github.com/spacebarlabs/apt.spacebarlabs.com

Assuming you're using Debian/Ubuntu:

```bash
sudo apt install yadm
yadm clone --recurse-submodules https://github.com/spacebarlabs/dotfiles
```

#### Post install

Vim plugins are managed as git submodules and will be automatically loaded by Vim's native package management.

### Updating

```bash
yadm pull
yadm submodule update
```
