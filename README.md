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

# Remove an entry by hostname
hoster remove www.example.com --dev

# List entries (all environments, or one)
hoster list
hoster list --dev

# Open an environment file in your editor
hoster edit --dev

# Preview what apply would change without touching the system hosts file
hoster diff --dev

# Apply an environment to /etc/hosts
hoster apply --dev

# Or apply every populated environment in one pass
hoster apply

# Show which environments are currently applied to the system hosts file
hoster status

# Sanity-check every env file (malformed IPs, duplicate hostnames)
hoster validate

# Diagnose the hoster install (deps, PATH, host file)
hoster doctor

# List atomic snapshots taken before each apply / clean
hoster history

# Restore one of them (requires sudo)
hoster history restore 20241108T143218Z-apply-dev.hosts

# Remove this project's entries from the system hosts file
hoster clean --dev

# Dump every environment as JSON (stdout) -- pipe into jq, redirect to a file, etc.
hoster export > backup.json

# Re-create the env files from a JSON backup
hoster import backup.json
```

`import` requires `jq`. Round-trip is byte-identical:
`hoster export | tee dump.json && rm -rf .hosts/* && hoster import dump.json` reproduces the original files exactly.

### Shell completion

**Bash** — `scripts/completion.bash`:

```sh
make install-completion           # /opt/homebrew/etc/bash_completion.d (macOS)
                                  # or /etc/bash_completion.d (Linux)
make install-completion COMPLETION_DIR=$HOME/.local/share/bash-completion/completions
```

Or source it directly from the repo for ad-hoc use:

```sh
source scripts/completion.bash
```

**Zsh** — `scripts/_hoster` (native, includes descriptions in the menu UI):

```sh
make install-zsh-completion       # /opt/homebrew/share/zsh/site-functions (macOS)
                                  # or /usr/local/share/zsh/site-functions (Linux)
make install-zsh-completion ZSH_COMPLETION_DIR=$HOME/.zsh/completions
```

After install, reload the shell or run `autoload -Uz compinit && compinit`.

### Man page

```sh
make install-man                  # /opt/homebrew/share/man/man1 or /usr/local equivalent
make install-man MAN_DIR=$HOME/.local/share/man/man1
```

Then `man hoster`.

Run `hoster --help` for the full command list and `hoster --version` to check the installed version. Pass `--verbose` (or `-v`) before any subcommand to surface the internal `run_cmd` invocations -- useful when debugging an `apply` or `clean` that does not seem to take effect.

`apply --prod` is gated: it refuses to run without `--force` so you can't fat-finger production. Use `hoster --force apply --prod` when you really mean it. The no-flag `apply` (which walks every populated env) is unaffected.

## Project metadata

By default the project name (used in the `##<name-env>##` markers
that `apply` writes to `/etc/hosts`) is the parent folder of `.hosts/`.
To override it without renaming the folder, drop a `.hosts/config`
file with:

```
name=my-project
```

Useful when the on-disk folder name differs from the project name
the team uses elsewhere (forks, monorepo paths, etc.).

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
