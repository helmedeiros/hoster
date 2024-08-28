# Contributing to hoster

Thanks for considering a contribution. The project is small and the bar for what to keep on disk is high, so the guidelines below help us spend review time on the change itself rather than on housekeeping.

## Local setup

```sh
git clone https://github.com/helmedeiros/hoster
cd hoster
make lint    # shellcheck
make test    # bats
make all     # both
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

## Tests

The suite follows a pyramid:

- Unit tests in `tests/*.bats` source a single module and call its functions directly.
- Integration tests (`tests/integration_*.bats`) shell out to `hoster.sh`.
- The smoke suite asserts the file layout so missing-file failures are obvious.

New behaviour needs a new test. New tests for existing behaviour are welcome on their own.

### Adding a new subcommand

A new subcommand typically touches **seven** places. Use the existing `clean` and `diff` work as templates:

1. **Route the keyword** in `builtin/handle_options.sh` (add a `case` branch that sets `COMMAND` and calls a `cmd_<name>_host` wrapper).
2. **Add wrappers** in `commands.sh` (`cmd_<name>_host` and `cmd_hosts_<name>`) and a branch in `cmd_execute_options`.
3. **Implement** the actual work in `builtin/host_actions.sh` or `builtin/host_apply.sh`.
4. **Unit test it**: `tests/<name>.bats` that stubs `sudo` and overrides `HOST_FILE` to a temp file.
5. **Wire it into `help.sh`** so `hoster --help` lists it.
6. **Document it** in `man/hoster.1` under COMMANDS (and re-render with `man man/hoster.1` to sanity-check the formatting).
7. **Update completions**: add the keyword to `scripts/completion.bash` (both the `subcommands` variable and the env-flag dispatch case) and `scripts/_hoster` (the `subcommands` array). `tests/completion_sync.bats` will catch you if you miss one.

The unit suite should not touch the real `/etc/hosts` -- always point `HOST_FILE` at a tempdir.

## Reporting issues

Use the [issue tracker](https://github.com/helmedeiros/hoster/issues). For security concerns please follow [SECURITY.md](SECURITY.md) instead of opening a public issue.
