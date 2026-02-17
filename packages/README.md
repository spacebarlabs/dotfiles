# Packages

This directory contains Debian package definitions for Space Bar Labs utilities.

## Package Structure

### sbl-cli-utils-core

The core package contains essential CLI utilities that work on resource-constrained systems like Devuan (Maemo Leste). This package includes:

- Basic shell utilities (bash, zsh)
- Version control (git)
- Network tools (curl, wget, openssh-client)
- Text processing (jq, less)
- Terminal multiplexing (tmux)
- Essential system tools (man-db, gnupg2, tree)

### sbl-cli-utils

The full CLI utilities package depends on `sbl-cli-utils-core` and adds:

- Advanced monitoring (btop)
- File watching (entr, inotify-tools)
- Enhanced file tools (fd-find, unar)
- Git extensions (git-annex, git-crypt)
- Text editors (neovim, micro)
- Version managers (mise)
- File management (trash-cli, yadm)
- Document conversion (pandoc)
- Text-based web browsers (lynx, w3m)
- JSON/YAML tools (gron)
- EXIF tools (libimage-exiftool-perl)
- Ruby environment
- Calendar utilities (ncal)
- REPL enhancement (rlwrap)

## Usage

### For Full Desktop/Server Systems

Install the full package which includes all utilities:

```bash
sudo apt install sbl-cli-utils
```

### For Resource-Constrained Systems (Devuan/Maemo Leste)

Install only the core package for essential utilities:

```bash
sudo apt install sbl-cli-utils-core
```

## Package Format

These files use the Debian control file format. They are intended to be used with tools that generate Debian packages from control files.

## Related Repositories

- [apt.spacebarlabs.com](https://github.com/spacebarlabs/apt.spacebarlabs.com) - APT repository for these packages
