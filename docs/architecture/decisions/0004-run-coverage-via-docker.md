# 4. Run Coverage Via Docker

## Status

Accepted

## Context

kcov is the standard tool for line coverage on shell scripts. Contributors come on two main platforms.

On macOS, the Homebrew formula for kcov lags upstream and has been broken on several Homebrew releases. Installing from source pulls in a long compiler toolchain.

On Linux, apt ships kcov but lags upstream and the package name varies across distros.

Either way, a "first contribution" friction point is "install a tool to run the coverage target you found in the Makefile". CI does not have that friction (it runs in a clean image and can `apt install` the world), but local development does.

## Decision

The Makefile target runs the official `kcov/kcov` Docker image with the repo bind-mounted at `/src`. Contributors need Docker, which is already common, and nothing else.

CI uses apt's kcov directly. The runners already have root and `apt-get install` is fast in a fresh image, so the Docker indirection adds no value there. The Makefile target and the CI workflow exist as parallel paths to the same outcome.

The CI workflow publishes the HTML report as an artifact named `coverage-html` with a 14-day retention, so a reviewer can pull the full per-line report on a PR without rerunning anything locally.

## Consequences

Contributors do not need to chase kcov on their host. The Docker image is the source of truth for the kcov version used to produce the report. Local and CI numbers are comparable.

Docker is an additional dependency to install when contributing. For users who already use it (common in this codebase's audience) the cost is zero. For users who do not, the alternative remains: install kcov via their package manager and call kcov directly. The target is convenience, not a requirement.

The report excludes `tests/` and `scripts/` so the number reflects production code coverage, not test-helper coverage.
