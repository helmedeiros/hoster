# hoster

[![Lint](https://github.com/helmedeiros/hoster/actions/workflows/lint.yml/badge.svg)](https://github.com/helmedeiros/hoster/actions/workflows/lint.yml)
[![Test](https://github.com/helmedeiros/hoster/actions/workflows/test.yml/badge.svg)](https://github.com/helmedeiros/hoster/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**hoster** keeps a project's `/etc/hosts` entries inside the repository, scoped per environment (local, dev, hlg, prod), and applies them on demand.

It is not always easy to discover the hosts an application needs. With hoster, every contributor sees the same `lcl/dev/hml/prd` host pairs alongside the code, and can swap them in and out of the system hosts file with one command.

**Supported platforms:** macOS (`/private/etc/hosts`), Linux (`/etc/hosts`), and Git Bash / MSYS / MinGW on Windows (`/c/Windows/System32/drivers/etc/hosts`). The system file is resolved at runtime via `$OSTYPE`.

## Table of contents

- [Install](#install)
- [Usage](#usage)
- [Development](#development)
- [Build](#build)
- [License](#license)

## Install

Clone, make the entrypoint executable, and add it to `PATH`:

```sh
git clone https://github.com/helmedeiros/hoster
cd hoster
chmod +x hoster
echo "export PATH=\"\$PATH:$(pwd)\"" >> ~/.zshrc   # or ~/.bashrc
source ~/.zshrc
```

## Usage

```sh
# Initialise an empty .hosts repository in the current project
hoster init

# Add an entry to a specific environment
hoster add 10.1.0.5 www.example.com --dev

# List entries (all environments, or one)
hoster list
hoster list --dev

# Open an environment file in your editor
hoster edit --dev

# Apply an environment to /etc/hosts
hoster apply --dev

# Remove this project's entries from the system hosts file
hoster clean --dev
```

Run `hoster --help` for the full command list and `hoster --version` to check the installed version.

## Development

Local quality checks go through `make`:

```sh
make lint    # shellcheck on all *.sh
make test    # bats test suite
make all     # lint + test
```

Both targets run in CI on every push and pull request.

## Build

The Maven assembly produces a release tarball:

```sh
mvn clean package
```

The build requires Maven 3.8+ and Java 11+ (enforced by `maven-enforcer-plugin`).

## License

[MIT](LICENSE) © Helio de Medeiros.
