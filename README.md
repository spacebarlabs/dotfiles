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

In `vim`, run `:PlugInstall` to install all Vim plugins

### Updating

```bash
yadm pull
yadm submodule update
```
