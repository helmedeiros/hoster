# 1. Adopt Hexagonal Layout

## Status

Accepted

## Context

hoster started as a single bash file in 2014. By the end of 2024 it had grown to 14 subcommands spread across two large files (`builtin/host_actions.sh` and `builtin/host_apply.sh`) plus helpers scattered through `commands.sh`. Pure logic, sudo wrangling, jq calls, JSON building, terminal coloring, and the wall clock were all mixed in the same call sites. Functions that should have been testable in isolation were either nested inside other functions or coupled to globals defined elsewhere.

The bash-vs-zsh basic-regex bug found in July and the BSD-getopt bug found in December both sat latent for years because nothing forced a separation between the verbs and the system calls they relied on.

## Decision

Split the source into three concentric layers, in the spirit of hexagonal / ports-and-adapters architecture.

- `core/` holds pure functions. No filesystem, no sudo, no clock, no terminal. Inputs arrive as arguments; outputs go to stdout or the exit status. Today this is one file, `core/pure.sh`, holding `valid_ip`, `json_escape`, `parse_host_line`, `env_to_filename`, `mk_marker_open`, `mk_marker_close`.

- `adapters/` holds one file per kind of side effect. `term.sh` for color and verbose logging. `clock.sh` for ISO-8601 timestamps. `fs.sh` for the backup directory. `sudo.sh` for the `priv_run` chokepoint. `json.sh` for the jq wrappers used by import. `os.sh` for the OSTYPE-driven host-file resolution.

- `builtin/` and `commands.sh` hold the verbs and the router. Each subcommand composes core and adapters to do its work.

The wiring (which case branch dispatches to which command) stays in `commands.sh` for now.

## Consequences

Each piece becomes testable in isolation. `tests/unit/` exercises core and adapters directly with no fixtures and no stubs. `tests/integration/` stubs sudo once and tests whole commands.

Cross-platform contracts have a home. macOS vs Linux differences belong in `adapters/os.sh` and `adapters/clock.sh` and nowhere else.

Privileged operations have one chokepoint. Auditing what hoster does as root means reading `adapters/sudo.sh`.

New commands are mechanical to add. Drop into the right file in `builtin/`, source from core and adapters, add a router branch in `commands.sh`, add an integration test. No surgery in a 400-line monolith.

The migration was carried out across 22 weekday commits in January 2025. Every commit kept `make all` green; no mid-migration broken state hit master. `git mv` preserved file history through the relocations.
