# dotfiles

The dotfiles we use. They use the [YADM](https://yadm.io/) format.

## Philosophy

Prefer git submodules over the various plugin managers (which often use git ultimately anyway).

The aim is to install dependencies (apt, etc) in a single command and then install dotfiles in a single command.

See also:

- [apt.spacebarlabs.com](https://apt.spacebarlabs.com)
- [browser-userscripts.spacebarlabs.com](https://browser-userscripts.spacebarlabs.com)

## Installation

Assuming you're using Debian/Ubuntu:

```bash
sudo apt install yadm
yadm clone --recurse-submodules https://github.com/spacebarlabs/dotfiles
yadm bootstrap
```

### Package Dependencies

These dotfiles work best with the Space Bar Labs CLI utilities packages:

- **Full systems** (desktop/server): Install `sbl-cli-utils` for the complete set of tools
- **Resource-constrained systems** (Devuan/Maemo Leste): Install `sbl-cli-utils-core` for essential utilities only

See the [packages](packages/) directory for detailed package definitions and what's included in each.

## Updating

```bash
yadm update
```

Or manually:

```bash
yadm pull
yadm refresh # see .gitconfig for details
yadm bootstrap
```

## Automated Maintenance

This repository uses a GitHub Actions workflow to automatically update all submodules weekly.  The workflow creates a pull request with the changes if updates are available and can be manually triggered from the Actions tab in GitHub.

This keeps all Vim plugins, Tmux plugins, and Oh My Zsh up-to-date automatically, similar to how Dependabot works for package dependencies.
