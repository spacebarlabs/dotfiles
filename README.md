# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Installation

See also: [apt.spacebarlabs.com](https://github.com/spacebarlabs/apt.spacebarlabs.com)

Assuming you're using Debian/Ubuntu:

```bash
sudo apt install yadm
yadm clone --recurse-submodules https://github.com/spacebarlabs/dotfiles
```

### Updating

```bash
yadm pull
yadm subup # see .gitconfig for details
```
