# Contributing to hoster

Thanks for considering a contribution. The project is small and the bar for what to keep on disk is high, so the guidelines below help us spend review time on the change itself rather than on housekeeping.

## Local setup

```sh
git clone https://github.com/helmedeiros/hoster
cd hoster
make lint            # shellcheck
make test            # bats
make all             # both
make install-hooks   # optional: pre-commit hook runs make all on every commit
```

Tools you'll want installed:

- [shellcheck](https://www.shellcheck.net/)
- [bats-core](https://github.com/bats-core/bats-core)
- bash 4+
- Maven 3.8+ and Java 11+ if you plan to touch `pom.xml`

## Branch and commit conventions

- Branch from `master`; name the branch after the issue or change (e.g. `quote-host_apply` or `49-reinit-fix`).
- Write commits in the imperative mood ("Quote …", not "Quoted …").
- Keep commits small and atomic. Each one must leave `make all` green.
- The CHANGELOG's `Unreleased` section is the source of truth for user-visible changes.

## Pull requests

- Open one PR per logical change.
- Make sure CI is green before requesting review.
- The PR description should answer **why** the change is needed; the diff already says what.

## Code layout

The codebase splits into three concentric layers (see [ADR-0001](docs/architecture/decisions/0001-adopt-hexagonal-layout.md) for the full reasoning):

- `core/` — pure functions. No I/O, no side effects. Easy to unit-test in isolation. Examples: `valid_ip`, `parse_host_line`, `json_escape`, `mk_marker_open`, `env_to_filename`.
- `adapters/` — wrappers around the outside world. One file per concern: `term.sh` (color, log), `clock.sh` (timestamps), `fs.sh` (backup dir), `sudo.sh` (`priv_run` chokepoint), `json.sh` (jq), `os.sh` (OSTYPE detection).
- `builtin/` and `commands.sh` — the verbs and the router. Compose `core/` + `adapters/` to do the user-visible work.

## Tests

The suite lives under `tests/` in two subfolders:

- `tests/unit/` — exercise one function in `core/` or `adapters/` directly. No fixtures. Fast (~1 second total).
- `tests/integration/` — drive whole commands or the `hoster.sh` entrypoint. Stub `sudo` and override `HOST_FILE` to a tmpdir so the suite never touches the real `/etc/hosts`.

Run them together or separately:

```sh
make test              # both
make test-unit         # tests/unit/ only
make test-integration  # tests/integration/ only
```

The integration suite includes a `smoke` test that asserts the file layout so missing-file failures point at the right thing, and a `completion_sync` test that fails if a new subcommand is added without updating every docs surface.

New behaviour needs a new test. New tests for existing behaviour are welcome on their own.

### Adding a new subcommand

A new subcommand typically touches **seven** places. Use the existing `clean` and `diff` work as templates:

1. **Route the keyword** in `builtin/handle_options.sh` (add a `case` branch that sets `COMMAND` and calls a `cmd_<name>_host` wrapper).
2. **Add wrappers** in `commands.sh` (`cmd_<name>_host` and `cmd_hosts_<name>`) and a branch in `cmd_execute_options`.
3. **Implement** the actual work in `builtin/host_actions.sh` or `builtin/host_apply.sh`. Use `core/` helpers for pure logic and `adapters/` for sudo, jq, the clock, or the filesystem.
4. **Unit test it**: `tests/integration/<name>.bats` if it touches the filesystem, `tests/unit/<name>.bats` if it stays pure. Stub `sudo` and point `HOST_FILE` at a tmpdir for any integration test.
5. **Wire it into `help.sh`** so `hoster --help` lists it.
6. **Document it** in `man/hoster.1` under COMMANDS (and re-render with `man man/hoster.1` to sanity-check the formatting).
7. **Update completions**: add the keyword to `scripts/completion.bash` (both the `subcommands` variable and the env-flag dispatch case) and `scripts/_hoster` (the `subcommands` array). `tests/integration/completion_sync.bats` will catch you if you miss one.

The unit suite should never touch the real `/etc/hosts` -- always point `HOST_FILE` at a tempdir.

## Reporting issues

Use the [issue tracker](https://github.com/helmedeiros/hoster/issues). For security concerns please follow [SECURITY.md](SECURITY.md) instead of opening a public issue.
