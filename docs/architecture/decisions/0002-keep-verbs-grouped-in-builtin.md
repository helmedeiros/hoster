# 2. Keep Verbs Grouped In builtin Rather Than One File Per Command

## Status

Accepted

## Context

The hexagonal split (ADR-0001) created `core/` and `adapters/`. The natural next step would be to push the same logic into the commands layer by giving each verb its own file: `commands/add.sh`, `commands/apply.sh`, and so on. That is the conventional shape in larger codebases.

hoster has 14 subcommands. They already live in two files: `builtin/host_actions.sh` (the project-file verbs: add, remove, list, edit, init, validate, doctor, export, import, open) and `builtin/host_apply.sh` (the system-hosts mutators plus their read-only siblings: apply, clean, diff, status, history). The two files share short helpers (`find_occurrence`, `remove_occurrence`) that are coupled to the grouping.

## Decision

Leave `builtin/` as a two-file folder. Treat it as the commands layer. Do not split per-verb until a single file crosses a length that hurts to read.

## Consequences

Fewer files in the repo. The grouping reflects the actual coupling: verbs that share helpers stay nearby.

Future verbs land in the file that holds their nearest relatives. A new project-file command goes into `host_actions.sh`; a new system-hosts mutator goes into `host_apply.sh`.

When a file does cross the ~500-line threshold, it gets split then, with a follow-up ADR explaining the new grouping. Until then, the cost of more files outweighs the cost of two larger ones.

The trade-off cost is real: a new contributor opening `host_actions.sh` reads ten unrelated commands before reaching the one they care about. The `make test-integration` output names every command, and `grep -n '^function ' builtin/` lists them quickly, so the navigation tax is bounded.
