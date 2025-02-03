# 3. Route Privileged Operations Through priv_run

## Status

Accepted

## Context

hoster modifies `/etc/hosts`, which requires root. The 2014 code called `sudo` inline at five sites in `host_apply.sh`: `sudo cp` for the temp swap, `sudo sed` for the marker extraction, `sudo chmod 777` to make the temp world-writable, and two more `sudo cp` calls for the final swap.

Auditing what hoster did as root meant grepping for `sudo` across every command file. Tests had to stub `sudo` as a function to avoid actually escalating, which left the assertion talking to the wrong layer.

Several of the inline calls used the older `run_cmd "sudo cp $a $b"` pattern, which builds a shell string and re-splits it on word boundaries. That pattern was already responsible for SC2086 cleanup work earlier in the year.

## Decision

Wrap every privileged operation behind `priv_run` in `adapters/sudo.sh`.

```sh
function priv_run(){
  sudo "$@"
}
```

Forwarded as `"$@"`, so arguments stay as arguments. No string-building. A `priv_run_str` companion accepts a single shell string for the legacy `run_cmd` callers that have not migrated yet.

Tests override `priv_run` (or just `sudo`, since the wrapper is one line) with a passthrough function.

## Consequences

One file to read when auditing what hoster runs as root.

Tests assert against the chokepoint, not the implementation. Stubs go in one place.

New mutating commands add one line. The cost of forgetting to escalate is now visible: a missing `priv_run` shows up as a permission denied at runtime, not as a silent failure.

The remaining direct `sudo` callers (a handful of `run_cmd "sudo cp ..."` invocations in `append_host` and the history restore path) are tagged for migration in a future cleanup. They still work, they just use the older string-builder; new code should prefer `priv_run`.
