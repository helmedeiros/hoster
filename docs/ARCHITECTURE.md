# Architecture

> Status: hexagonal layout is in place as of the January 2025 cycle. `core/` and `adapters/` exist and host the pieces described below. The remaining `builtin/` files are the **commands** layer (verbs that compose core + adapters) — they have not been split further because the grouping is already reasonable, and one-file-per-command would multiply files without payoff.

## Snapshot

| Layer | Files | Tests |
|---|---|---|
| `core/`     | 1 (5 functions) | 74 unit |
| `adapters/` | 6               | shared with integration |
| `builtin/` + `commands.sh` | 5 | 141 integration |

Run `make test` for the full 215. Coverage at `make coverage`.

## The three layers

hoster is a bash CLI. We organise its source into three concentric layers, in the spirit of hexagonal / ports-and-adapters architecture:

```
   ┌──────────────────────────────────────────┐
   │                commands/                 │   user-facing verbs
   │   add, apply, clean, diff, doctor, …     │
   ├──────────────────────────────────────────┤
   │                adapters/                 │   I/O at the edges
   │   sudo, fs, clock, term, json, os        │
   ├──────────────────────────────────────────┤
   │                  core/                   │   pure functions
   │   valid_ip, parse_host_line, json_escape │
   └──────────────────────────────────────────┘
```

### `core/` — pure functions

No side effects. No `sudo`, no filesystem, no clock, no terminal. Takes inputs, returns outputs (or exit status). Easy to test in isolation, trivially fast.

Examples that belong here:

- `valid_ip "$ip"` — exit 0 if the string parses as an IPv4 address.
- `json_escape "$value"` — emit the same string with `\\` and `\"` escaped.
- `parse_host_line "$line" → ip host` — classify a host-file line.
- `env_to_filename dev → hosts.dev` — map an env key to the on-disk file name.
- `mk_marker_open <project> <env>` → `##<project-env>##`.

### `adapters/` — the outside world

A thin wrapper per kind of side effect. Tests stub these.

| Adapter | What it owns |
|---|---|
| `adapters/term.sh`   | `hoster_color`, `hoster_log`, TTY / `NO_COLOR` detection |
| `adapters/fs.sh`     | atomic writes, the backup directory layout |
| `adapters/clock.sh`  | ISO-8601 UTC timestamps |
| `adapters/sudo.sh`   | `priv_run` — the single chokepoint for privileged operations |
| `adapters/json.sh`   | `jq` invocations for import |
| `adapters/os.sh`     | `hoster_os_*` predicates and `hoster_os_host_file` |

### `commands/` — the verbs

Each subcommand is composed from core + adapters. A typical command file:

```sh
# commands/apply.sh
source core/markers.sh
source adapters/fs.sh
source adapters/sudo.sh

hosts_apply() {
  local marker_open marker_close
  marker_open="$(mk_marker_open "$PROJECT_NAME" "$ENVIRONMENT")"
  marker_close="$(mk_marker_close "$PROJECT_NAME" "$ENVIRONMENT")"

  fs_backup "$HOST_FILE" "apply-$ENVIRONMENT"
  priv_run write_marker_block "$marker_open" "$PROJECT_FILE" "$marker_close" "$HOST_FILE"
}
```

The wiring (which `case` branch dispatches to which command) stays in `commands.sh` for now.

## What this buys us

- **Tests get faster and clearer.** `tests/unit/` exercises `core/` directly with no stubs. `tests/integration/` stubs `sudo` and `priv_run` once and tests whole commands.
- **Cross-platform contracts have a home.** macOS-vs-Linux differences belong in `adapters/os.sh` and `adapters/clock.sh`; nowhere else.
- **Privileged operations have one chokepoint.** Auditing what hoster does as root means reading `adapters/sudo.sh`.
- **New commands are mechanical to add.** Drop a file in `commands/`, add a router entry in `commands.sh`, add an integration test. No surgery in `host_actions.sh`.

## Migration log (January 2025)

| Week | Status | What landed |
|---|---|---|
| Jan 6–10  | ✅ | `core/pure.sh` holds `valid_ip`, `json_escape`, `parse_host_line`, `env_to_filename`, `mk_marker_open` / `_close`. Each pure function has its own unit test. |
| Jan 13–17 | ✅ | `adapters/term.sh` (color + log), `adapters/clock.sh`, `adapters/fs.sh` (backup), `adapters/sudo.sh` (`priv_run` chokepoint), `adapters/json.sh` (jq wrapper). `os.sh` moved into `adapters/`. |
| Jan 20–24 | ✅ | `tests/` split into `tests/unit/` (74) and `tests/integration/` (140+); CI matrix runs Ubuntu × macOS × bash 4 × bash 5; dead `builtin/paths.sh` removed. |
| Jan 27–31 | ✅ | `make coverage` runs kcov via Docker; CI publishes coverage as an artifact; `1.14.0-SNAPSHOT` cycle held — next tag cuts when the verbs migrate. |

Every commit in the cycle left `make all` green: each function move was paired with a call-site update, the old definition deleted, lint and tests still passing. No mid-migration broken state hit master.

## Out of scope for this cycle

- Splitting `commands/` into one file per subcommand. The verbs already live in `host_actions.sh` and `host_apply.sh` and the grouping there is reasonable; splitting further would multiply files without much payoff.
- Replacing `bash` with something else. The whole point of hoster is to be a small, dependable shell tool.
- A plugin system. Maybe in a future cycle.
