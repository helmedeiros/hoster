# Security Policy

## Supported versions

Only the latest release tag receives security fixes. Older tags are kept for archival purposes.

| Version | Supported |
|---------|-----------|
| latest  | yes       |
| older   | no        |

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security problems.

Instead, use GitHub's private vulnerability reporting:

> <https://github.com/helmedeiros/hoster/security/advisories/new>

Include:

- a clear description of the issue,
- steps to reproduce,
- the version or commit you tested against,
- any proposed remediation if you have one.

You should receive an acknowledgement within seven days. If the issue is confirmed, a fix and a release timeline will be communicated back to you before any public disclosure.

## Scope

hoster manipulates `/etc/hosts` via `sudo`. Reports that fall in scope include:

- Privilege-escalation bugs in the apply/find/remove flow.
- Command injection through host or IP arguments.
- Path traversal in the `.hosts` repository layout.

Out of scope: misconfigurations of the operator's own machine, social-engineering vectors, and issues that require already-root access.
