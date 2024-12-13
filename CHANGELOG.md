# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `open` subcommand: prints `https://<host>` (one line per host)
  for the named environment, or every populated environment when
  no flag is given. Scheme is overridable via
  `HOSTER_OPEN_SCHEME`. Pipe into `open(1)` / `xdg-open(1)` to
  launch a browser, or feed into a smoke-test script.
- Global `--force` / `-f` flag, consumed in place like
  `--verbose`.
- `apply --prod` is now gated behind `--force`. The no-flag
  `apply` (which walks every populated env via `apply_all`) is
  unaffected.

### Changed

- `handle_env_options` no longer relies on GNU `getopt -l`
  (BSD getopt on macOS does not support it). Replaced with a
  hand-rolled for-loop scan over the forwarded arguments. The
  bug was latent since 2014 -- existing tests pre-set
  `ENVIRONMENT` so it never surfaced; `hoster open --dev`
  exposed it.

### Older Unreleased (carried over from 1.13.0-SNAPSHOT cycle)

- `history` subcommand: lists atomic backups under
  `.hosts/backup/` (oldest first) and `history restore <file>`
  rolls one back via `sudo`, after first snapshotting the
  current state to a `pre-restore.hosts` safety backup.
- Atomic backups: every `apply` and every non-no-op `clean`
  now snapshots the system hosts file to
  `.hosts/backup/<timestamp>-<reason>.hosts` before mutating.
  `hoster_backup` is the shared helper.
- `.hosts/config` with `name=<value>` overrides the
  folder-derived project name in the `##<name-env>##` markers.
  Comments and blanks in the config are ignored.
- `doctor` gains a `Project:` section reporting the presence
  of `.hosts/config` (optional check) when run inside a
  project.
- 22 new tests (suite at 178): hoster_backup (5), apply +
  clean backup behaviour (3), hosts_history (8), and
  cmd_project_name override + 5 fallback paths.
- `.gitignore` template ignores `.hosts/backup/`.
- `examples/sample-project` gains a `.hosts/config` file
  demonstrating the override.

### Older Unreleased (carried over from 1.12.0-SNAPSHOT cycle)

- `validate` subcommand: scans every env file and reports
  invalid IPs and duplicate hostnames as errors (exit 1) and
  malformed lines as warnings (exit 0). Comments and blank
  lines are ignored.
- `doctor` subcommand: diagnoses the hoster install (bash
  version, host file readability, `jq` / `shellcheck` / `bats`
  presence, PATH wiring, `hoster.version` readability) and
  exits non-zero only when a required check fails.
- `apply` with no environment flag walks every populated
  environment in order; empty files are skipped.
- Comment and blank-line preservation through `export`/`import`.
  The JSON schema is now typed (`entry`/`comment`/`blank`);
  `import` also accepts the legacy 1.10/1.11 flat shape so
  earlier dumps still load.
- `examples/sample-project` ready-to-run fixture.
- 24 new tests (suite at 156): hosts_validate (9), hosts_doctor
  (6), hosts_apply_all (4), typed export (3), comment-aware
  round-trip (2).

### Changed

- `die` uses `$*` instead of `$@` when building the error
  message; `valid_ip` uses `IFS=. read -r -a octets <<< "$ip"`
  instead of the OIFS/IFS dance. Both close out the last
  pair of fixable shellcheck warnings (SC2145, SC2206);
  baseline disable list shrinks to four cross-file codes.

### Initial release line

- `diff` subcommand: read-only preview of what `apply` would change.
  Extracts the project's currently-applied block (if any) and runs
  `diff -u` against the project's env file; falls back to printing
  the project file as a "would-add" view when nothing is applied.
- `man/hoster.1` man page covering all ten subcommands, the global
  flags, the four environment flags, the per-platform host file
  paths, two worked examples, and a SEE ALSO line for `hosts(5)`
  and `sudo(8)`.
- Native zsh completion at `scripts/_hoster` with descriptions in
  the menu-select UI.
- `make install-zsh-completion` and `make install-man` targets,
  both with Homebrew / Linux defaults and a `*_DIR` override knob.
- `.github/workflows/release.yml` builds the Maven assembly on
  every `v*` tag push and publishes the tarball + checksum as a
  GitHub release.
- `--dry-run` / `-n` flag and three precondition guards (version
  format, dirty working tree, tag-exists) in `scripts/release.sh`.
- `tests/completion_sync.bats` pins the routed-subcommand list in
  `handle_options.sh` against `completion.bash`, `_hoster`,
  `man/hoster.1` and `help.sh` so the four docs surfaces cannot
  drift.

### Changed

- CONTRIBUTING.md subcommand recipe expanded from four steps to
  seven (help, man page, both completions).

## [1.13.0] - 2024-12-02

Fourth tagged release. Builds on 1.12.0 with the November work:

- `history` subcommand (list backups; restore one with sudo).
- Atomic backups on every `apply` and non-no-op `clean`.
- `.hosts/config` `name=<value>` project-name override.
- `doctor` reports config presence when run inside a project.
- 22 new tests; suite at 178.

## [1.12.0] - 2024-11-01

Third tagged release. Builds on 1.11.0 with the October work:

- `validate` subcommand for IP and duplicate-host checks.
- `doctor` subcommand for diagnosing the install.
- `apply` with no flag walks every populated environment.
- Comment + blank-line preservation through `export` / `import`
  via a new typed JSON schema; the legacy 1.10/1.11 flat shape
  still imports.
- `examples/sample-project/` fixture demonstrating a realistic
  layout with comments.
- Lint fixes (`die` `$*`, `valid_ip` `read -r -a`) shrink the
  shellcheck baseline to four cross-file codes.
- Suite at 156 tests.

## [1.11.0] - 2024-09-30

Second tagged release. Builds on the 1.10.0 surface with the
August + September work:

- `diff` subcommand (read-only preview of what `apply` would change).
- `export` / `import` for byte-identical JSON round-trip of all
  four environments. `export` is hand-rolled (no deps); `import`
  uses `jq`.
- Colored output for `list`, `status`, and `diff` -- gated on isatty
  and `NO_COLOR` so pipes and CI stay plain.
- `man/hoster.1` man page covering every subcommand, the EXPORT
  FORMAT section, and worked examples.
- Native zsh completion at `scripts/_hoster` plus the existing bash
  completion at `scripts/completion.bash`. File-path completion
  after `import`.
- `install-completion`, `install-zsh-completion`, `install-man`,
  `install-hooks` Make targets.
- `release.sh` hardened with `--dry-run` and three precondition
  guards. Release CI on `v*` tags publishes the tarball + checksum.
- `tests/completion_sync.bats` pins the routed-subcommand list
  against `completion.bash`, `_hoster`, `man/hoster.1`, `help.sh`.
- Test suite now 132 cases.

## [1.10.0] - 2024-08-05

First tagged release since `1.7.2-IURI` (2014-12-02). Includes the
full April–July modernisation: testing infrastructure (104 bats
cases across unit, integration and smoke), shellcheck baseline
shrunk from 15 codes to 6, OS abstraction for macOS/Linux/Windows
host file resolution, the `clean`, `remove`, `status` subcommands,
`--verbose` flag, `parse_env_arg` position-agnostic environment
parsing, bash completion, hardened `scripts/release.sh`, and the
build modernisation under Maven 3.8+ / Java 11+.

See the `[1.10.0-SNAPSHOT]` / `[1.9.0-SNAPSHOT]` /
`[1.8.0-SNAPSHOT]` sections for the detailed diff against
1.7.2-IURI.

### Older diff (carried over from 1.10.0-SNAPSHOT)

- `remove` subcommand (and `rm` alias) to delete a single host by
  name from one environment's host file. Uses anchored matching so
  a hostname that is a prefix of another (e.g. `www.example.com`
  vs `www.example.com.staging`) is not over-deleted.
- `status` subcommand: scans the system hosts file for the current
  project's marker blocks and lists the environments currently
  applied.
- `--verbose` / `-v` global flag. Consumed by `handle_main_options`
  ahead of any subcommand and exposed through a new `hoster_log`
  helper. `run_cmd`'s "Running: ..." banner is now gated on this
  flag; default output is quiet.
- `parse_env_arg` helper that scans all forwarded arguments for the
  environment flag, so users can write `hoster add --dev 10.0.0.1
  host` or `hoster add 10.0.0.1 host --dev` interchangeably.
- Bash completion script at `scripts/completion.bash` plus
  `make install-completion` (Homebrew or system path, overridable).
- 29 new tests bringing the suite to 104 cases: `host_remove`,
  `hoster_log`, `append_host` (write path + idempotency +
  other-project isolation), `hosts_list`, `hosts_status`, and
  `--verbose` integration.
- `versions-maven-plugin` so plugin/dependency audits are one
  command away.

### Changed

- `run_cmd` rewritten to check the exit status directly with
  `if ! $1` (drops SC2181 from the shellcheck baseline) and to
  route the per-call banner through `hoster_log`.
- `add_host`, `remove_host`, `list_host`, `edit_host`, `apply_host`
  and `clean_host` now call `parse_env_arg "$@"` instead of
  picking a positional slot, so the environment flag works in
  any position.
- `pom.xml` gains `project.reporting.outputEncoding=UTF-8`.

### [Older Unreleased entries from April-June below]

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

## [1.10.0-SNAPSHOT] - 2024-07-31

Snapshot capturing the July work: `remove` and `status` subcommands,
`--verbose` flag, `parse_env_arg` refactor making the environment
flag position-agnostic, bash completion script, and 29 new tests
bringing the suite to 104 cases.

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

[Unreleased]: https://github.com/helmedeiros/hoster/compare/v1.13.0...HEAD
[1.13.0]: https://github.com/helmedeiros/hoster/compare/v1.12.0...v1.13.0
[1.12.0]: https://github.com/helmedeiros/hoster/compare/v1.11.0...v1.12.0
[1.11.0]: https://github.com/helmedeiros/hoster/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/helmedeiros/hoster/compare/v1.7.2-IURI...v1.10.0
[1.10.0-SNAPSHOT]: https://github.com/helmedeiros/hoster/compare/v1.9.0-SNAPSHOT...v1.10.0-SNAPSHOT
[1.9.0-SNAPSHOT]: https://github.com/helmedeiros/hoster/compare/v1.8.0-SNAPSHOT...v1.9.0-SNAPSHOT
[1.8.0-SNAPSHOT]: https://github.com/helmedeiros/hoster/compare/v1.7.2-IURI...v1.8.0-SNAPSHOT
[1.7.2-IURI]: https://github.com/helmedeiros/hoster/releases/tag/v1.7.2-IURI
