# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `clean` subcommand. Reverse of `apply`: removes the current project's
  block from the system hosts file. Implemented in
  `builtin/host_apply.sh` (`clean_host` / `hosts_clean`) on top of
  the existing `find_occurrence` / `remove_occurrence` primitives,
  with unit tests covering the no-op path, the matching-block
  removal and the "do not touch other-project blocks" guarantee.
- `builtin/os.sh` exposing `hoster_os_is_macos` /
  `hoster_os_is_linux` / `hoster_os_is_windows` and a
  `hoster_os_host_file` resolver, ported in concept from the
  abandoned ruby branch. `define_defaults` now sources os.sh and
  derives `HOST_FILE` and `HOST_PATH` from it, so hoster works on
  Linux (`/etc/hosts`) and Git Bash / MSYS / MinGW
  (`/c/Windows/System32/drivers/etc/hosts`).
- Test suite grew from 50 to 75 cases; new unit suites for
  `hoster_os_*`, `find_occurrence`, `hosts_clean`, and a
  `tests/integration_os.bats` exercising the full source chain.

### Changed

- `environments` array moved from `builtin/host_actions.sh` to
  `builtin/defaults.sh` (configuration belongs with constants).
- Makefile lint target now runs `shellcheck -x` so the
  `# shellcheck source=…` directives are followed.
- `help.sh` lists `apply` and `clean` alongside the original
  add / edit / init / list commands.

### Initial

- `.gitignore` covering Maven build outputs and OS files.
- MIT `LICENSE`.
- `.editorconfig` codifying indent and newline conventions.
- `.shellcheckrc` establishing a green lint baseline.
- `Makefile` with `lint`, `test`, `all`, `clean` targets.
- `tests/` suite using bats: unit tests for `valid_ip`,
  `define_defaults`, `cmd_set_environment`, `handle_main_options`,
  `hosts_init`, `run_cmd`, `die`, `define_ip`; integration tests for
  `--version`, `--help` and the no-arg invocation.
- GitHub Actions workflows for shellcheck and bats.
- `scripts/release.sh` helper that bumps `hoster.version`, rewrites
  the project `<version>` in `pom.xml` and tags the release.
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`.
- `maven-enforcer-plugin` pinning the build to Maven 3.8+ and Java 11+.

### Changed

- `commands.sh`, `hoster.sh` and `version.sh` resolve sourced paths
  from `${BASH_SOURCE[0]}` so the modules can be sourced from a test
  harness without depending on `$0`.
- Quoted `$(dirname …)` and forwarded `"$@"` across all modules to
  clear SC2046 / SC2068 / SC2086. The shellcheck baseline disable
  list shrank from 15 codes to 7.
- `append_host` groups its three sequential `>>` redirects into one,
  and `find_occurrence` / `remove_occurrence` route sudo output via
  `tee` to drop SC2024.
- Removed the dead `cmd_close_when_no_parameters` helper (the call
  sites were unreachable and the implementation relied on `break`
  leaking out of a function, SC2104).
- Bumped `maven-assembly-plugin` from 2.4 to 3.7.1.
- Replaced the unmaintained `shell-maven-plugin` 1.0-beta-1 with
  `exec-maven-plugin` 3.5.0 and switched the release checksum from
  sha1 to sha256.
- Refreshed `Library/Build/assembly.xml` against the 2.2.0 schema and
  included `LICENSE` and `CHANGELOG.md` in the release tarball.
- Modernised the Homebrew formula: added `desc` and `license`, fixed
  the upstream URL, pinned sha256, replaced the `:python` symbol dep
  with `python3` in the install step.
- README rewritten with badges, table of contents and modern install
  steps.

## [1.9.0-SNAPSHOT] - 2024-06-28

Snapshot capturing the June work: OS abstraction, `clean`
subcommand, the lift of temp-file basenames into defaults, and 25
new tests bringing the suite to 75 cases.

## [1.8.0-SNAPSHOT] - 2024-05-31

Snapshot capturing the April-May work. Next tagged release will cut
from here.

## [1.7.2-IURI] - 2014-12-02

### Added

- Logic to reinitialize an existing host repository.
- `hoster init` for empty host repositories.

[Unreleased]: https://github.com/helmedeiros/hoster/compare/v1.9.0-SNAPSHOT...HEAD
[1.9.0-SNAPSHOT]: https://github.com/helmedeiros/hoster/compare/v1.8.0-SNAPSHOT...v1.9.0-SNAPSHOT
[1.8.0-SNAPSHOT]: https://github.com/helmedeiros/hoster/compare/v1.7.2-IURI...v1.8.0-SNAPSHOT
[1.7.2-IURI]: https://github.com/helmedeiros/hoster/releases/tag/v1.7.2-IURI
