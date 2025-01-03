# Architecture

> Status: in transition. This document describes the **target** shape the codebase is being refactored toward over the January 2025 cycle. Pieces that already live in their target home are marked ✅; pieces still in their legacy location are marked ⏳.

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

## Migration plan (January 2025)

| Week | Move |
|---|---|
| Jan 6–10  | ⏳ extract `core/pure.sh` (valid_ip, json_escape, parse_host_line, env_to_filename, mk_marker) |
| Jan 13–17 | ⏳ extract `adapters/term.sh`, `adapters/fs.sh`, `adapters/clock.sh`, `adapters/sudo.sh`, `adapters/json.sh`; move `os.sh` → `adapters/os.sh` |
| Jan 20–24 | ⏳ reorganise `tests/` into `tests/unit/` and `tests/integration/`; CI matrix (macOS+Linux × bash 4+5); drop dead `builtin/paths.sh` |
| Jan 27–31 | ⏳ add `make coverage`; gap-fill; CHANGELOG; hold 1.14.0-SNAPSHOT |

Each commit during the migration leaves `make all` green: the function moves, every call site picks it up from the new home, the old definition is deleted, lint and tests stay green. No mid-migration broken state hits master.

## Out of scope for this cycle

- Splitting `commands/` into one file per subcommand. The verbs already live in `host_actions.sh` and `host_apply.sh` and the grouping there is reasonable; splitting further would multiply files without much payoff.
- Replacing `bash` with something else. The whole point of hoster is to be a small, dependable shell tool.
- A plugin system. Maybe in a future cycle.
