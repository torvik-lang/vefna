# Contributing to Vefna

Thanks for wanting to help weave. Vefna is deliberately small — one binary that
turns Markdown into HTML, written entirely in
[Torvik](https://github.com/torvik-lang/torvik) — and contributions that keep
it small, fast, and predictable are very welcome.

## Before you start

- **Bugs**: open an issue with your platform, `vefna version` output, and the
  smallest site that reproduces the problem. A zipped minimal project is gold.
- **Features**: check [ROADMAP.md](ROADMAP.md) first — including the
  **non-goals** section — and open an issue to discuss before building anything
  sizable. It's no fun to write a big PR that doesn't fit the tool's direction.
  (For example, `vefna serve` is deliberately waiting on HTTP support in Torvik
  itself rather than shelling out to an external server.)
- **Small fixes** (typos, docs, an obvious bug with a test): just send the PR.

## Getting set up

1. Install the Torvik toolchain. Vefna needs at least the version named in
   `torvik.rune` (currently **Torvik v1.4.0**) — a newer toolchain is fine:

   ```
   curl -fsSL https://raw.githubusercontent.com/torvik-lang/torvik/main/linux/install.sh | sh
   ```

   (Windows: the `install.ps1` equivalent — see the Torvik README. You'll also
   need `clang` on Linux.)

2. Build and test:

   ```
   rune build --final
   bash tests/run_tests.sh build/vefna                              # Linux
   powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1     # Windows
   ```

   All tests must pass before and after your change. If you can only test one
   platform, say so in the PR — the other gets verified before merge.

## Project conventions

- **One platform-independent source tree.** Everything in `src/` compiles and
  behaves identically on Linux and Windows. No platform-specific branches
  unless truly unavoidable — and none exist today.
- **No globals in worker-reachable code.** `vefna_worker` and everything it
  calls runs under `raven`, and Torvik enforces that spawned code is
  self-contained. In practice the whole project uses zero globals; keep it
  that way.
- **Determinism is a feature.** The same inputs must produce a byte-identical
  site on every platform. Anything that introduces ordering dependent on hash
  iteration, thread timing, or platform quirks is a bug — the test suite's
  determinism case will catch it.
- **Style**: 4-space indentation, one concern per module (`md.tv` renders
  Markdown, `fm.tv` parses front matter, and so on), conservative expression
  style matching the surrounding code.

## Tests

Every behavior change needs a test. The suite lives in `tests/`:

- **Behavioral cases** live in the runners (`run_tests.sh` / `run_tests.ps1`) —
  keep the two in sync; they mirror each other case for case.
- **Golden files**: `tests/fixture/` is a small site exercising every feature;
  `tests/golden/` is its blessed output. If your change legitimately alters
  output, rebuild the fixture (`vefna build --clean` inside a copy of it),
  **review the HTML diff by hand**, and update `tests/golden/` with the result.
  Never regenerate goldens without reading the diff — that's the moment bugs
  get blessed.
- Fixture and golden files are marked `-text` in `.gitattributes` so they stay
  byte-exact across platforms. Don't "fix" their line endings.
- Don't commit `build/` or `tests/tmp/`.

## Pull requests

- Small and focused beats large and sweeping. One change per PR.
- Describe the behavior before and after, not just the code.
- Update docs that the change touches (README for user-facing behavior,
  CHANGELOG.md under an "Unreleased" heading).

## Licensing

Vefna is licensed under **AGPL-3.0** (see [LICENSE](LICENSE)). By submitting a
contribution you agree it's provided under the same license. The sites Vefna
generates are, as ever, entirely yours.
