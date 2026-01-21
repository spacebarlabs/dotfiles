# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Philosophy

Prefer git submodules over the various plugin managers (which often use git ultimately anyway).

The aim is to install dependencies (apt, etc) in a single command and then install dotfiles in a single command.

See also: [apt.spacebarlabs.com](https://github.com/spacebarlabs/apt.spacebarlabs.com)

## Installation

Assuming you're using Debian/Ubuntu:

```bash
sudo apt install yadm
yadm clone --recurse-submodules https://github.com/spacebarlabs/dotfiles
```

## Updating

```bash
yadm pull
yadm subup # see .gitconfig for details
```
