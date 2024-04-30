# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `.gitignore` covering Maven build outputs and OS files.
- MIT `LICENSE`.
- `.editorconfig` codifying indent and newline conventions.
- `.shellcheckrc` establishing a green lint baseline.
- `Makefile` with `lint`, `test`, `all`, `clean` targets.
- `tests/` suite using bats: unit tests for `valid_ip`,
  `define_defaults`, `cmd_set_environment`, `handle_main_options`,
  `hosts_init`; integration tests for `--version`, `--help` and the
  no-arg invocation.
- GitHub Actions workflows for shellcheck and bats.

### Changed

- `commands.sh`, `hoster.sh` and `version.sh` resolve sourced paths
  from `${BASH_SOURCE[0]}` so the modules can be sourced from a test
  harness without depending on `$0`.
- Quoted `$(dirname …)` and forwarded `"$@"` in `commands.sh` and
  `hoster.sh` to fix the SC2046 / SC2068 findings.
- Bumped `maven-assembly-plugin` from 2.4 to 3.7.1.

## [1.7.2-IURI] - 2014-12-02

### Added

- Logic to reinitialize an existing host repository.
- `hoster init` for empty host repositories.

[Unreleased]: https://github.com/helmedeiros/hoster/compare/v1.7.2-IURI...HEAD
[1.7.2-IURI]: https://github.com/helmedeiros/hoster/releases/tag/v1.7.2-IURI
