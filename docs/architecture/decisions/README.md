# Architecture Decision Records

Each file in this folder captures one architecture decision made on the hoster codebase, following the standard ADR shape (Status / Context / Decision / Consequences).

New decisions get the next number and a short kebab-case slug:

```
NNNN-short-decision-name.md
```

A decision is "Accepted" when its implementation is on master. Older decisions can be marked "Superseded by ADR-MMMM" and kept in place so the history of the codebase reads as a sequence of choices.

## Index

- [ADR-0001 Adopt Hexagonal Layout](0001-adopt-hexagonal-layout.md)
- [ADR-0002 Keep Verbs Grouped In builtin Rather Than One File Per Command](0002-keep-verbs-grouped-in-builtin.md)
- [ADR-0003 Route Privileged Operations Through priv_run](0003-route-privileged-operations-through-priv-run.md)
- [ADR-0004 Run Coverage Via Docker](0004-run-coverage-via-docker.md)
