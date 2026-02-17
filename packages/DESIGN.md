# Package Split Design Document

## Overview

This document explains the rationale and design decisions for splitting `sbl-cli-utils` into `sbl-cli-utils-core` and `sbl-cli-utils`.

## Motivation

Maemo Leste is a mobile operating system based on Devuan that runs on resource-constrained devices like the PinePhone. The original `sbl-cli-utils` package included many dependencies that:

1. May not be available or easily installable on Devuan/Maemo Leste
2. May consume too much storage space on mobile devices
3. May have complex dependencies that are unnecessary for basic dotfiles usage

## Design Principles

### sbl-cli-utils-core

**Target Audience**: Mobile devices, embedded systems, minimal installations

**Selection Criteria**:
- Essential for basic command-line work
- Lightweight with minimal dependencies
- Available in standard Devuan repositories
- Critical for dotfiles functionality

**Included Packages**:
- Shell environments: bash, zsh
- Version control: git
- Network utilities: curl, wget, openssh-client
- Text processing: jq, less
- Terminal multiplexing: tmux
- Security: gnupg2
- File utilities: tree
- Documentation: man-db
- Repository configuration: sbl-apt-repos

### sbl-cli-utils

**Target Audience**: Desktop systems, servers, full installations

**Selection Criteria**:
- Enhanced productivity tools
- Development utilities
- May have larger dependencies or be unavailable on minimal systems

**Additional Packages** (beyond core):
- Monitoring: btop
- File watching: entr, inotify-tools
- Enhanced search: fd-find
- Git extensions: git-annex, git-crypt
- Advanced editors: neovim, micro
- Version managers: mise
- Document processing: pandoc
- Text browsers: lynx, w3m
- Data tools: gron
- Metadata: libimage-exiftool-perl
- File management: trash-cli, yadm, unar
- Development: ruby, rlwrap
- Calendar: ncal

## Dependency Relationship

```
sbl-cli-utils
    └── depends on sbl-cli-utils-core
            └── depends on bash, curl, git, etc.
```

This ensures:
1. Installing `sbl-cli-utils` automatically gets core packages
2. Users can install only `sbl-cli-utils-core` on constrained systems
3. Package maintainers have a clear separation of concerns

## Installation Scenarios

### Full Desktop/Server Installation
```bash
sudo apt install sbl-cli-utils
# Gets both core and additional utilities
```

### Mobile/Embedded Installation (Maemo Leste)
```bash
sudo apt install sbl-cli-utils-core
# Gets only essential utilities
```

## Migration Path

For existing users:
- No changes required
- Installing `sbl-cli-utils` continues to work
- All previous dependencies are preserved
- The package is simply reorganized internally

## Testing

The GitHub Actions workflow continues to use `sbl-cli-utils` to ensure:
1. Full compatibility with existing installations
2. All dotfiles work with the complete toolset
3. No regressions in functionality

## Future Considerations

1. **Platform-specific packages**: Consider creating platform-specific packages (e.g., `sbl-cli-utils-mobile`, `sbl-cli-utils-desktop`)
2. **Optional features**: Some tools (like `mise`, `git-annex`) could be split into optional packages
3. **Alternative cores**: Consider minimal core variants for different use cases (development vs. administration)

## Related Work

- [apt.spacebarlabs.com](https://github.com/spacebarlabs/apt.spacebarlabs.com) - Package repository
- [Maemo Leste](https://maemo-leste.github.io/) - Target platform documentation
- [Devuan](https://www.devuan.org/) - Base distribution
