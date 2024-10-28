# sample-project

A tiny fixture showing what a hoster-managed project looks like on disk.

Copy this folder anywhere outside the hoster repo, `cd` into it, and try the read-only commands:

```sh
hoster list
hoster list --dev
hoster validate
hoster export
```

The four files under `.hosts/` are what `hoster init` creates, then populated with a couple of entries per environment plus a comment in `hosts.dev` to show what comment preservation looks like through `export` / `import`.
