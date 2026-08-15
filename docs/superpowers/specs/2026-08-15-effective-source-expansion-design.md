# MoonPlot Effective Source Expansion Design

**Goal:** Expand MoonPlot with real data-analysis and visualization capabilities so production MoonBit code exceeds 4,000 effective lines while improving boundary coverage and acceptance readiness.

## Scope

- Add CSV/table profiling with numeric and categorical column summaries.
- Add deterministic simple linear regression with safe degenerate-input behavior.
- Add reusable area and heatmap series for both existing backends.
- Extract benchmark/report logic into testable functions and add runnable examples.
- Update public documentation, benchmark provenance, changelog, and acceptance notes.

## Architecture

The new data APIs remain pure and filesystem-independent so WASM, WASM-GC, JS, and native targets share behavior. Regression owns only numeric model calculations and returns plain public records. Area and heatmap series depend on the existing `Backend` and `Scale` traits, reusing current coordinate mapping, color interpolation, and bounds conventions instead of introducing a second rendering path.

All new public types live in the existing `src/data`, `src/stats`, and `src/series` public packages. Tests are package-local black-box tests and cover valid paths, empty inputs, invalid parameters, constant data, negative values, and renderer escaping. Examples remain executable and deterministic.

## Acceptance constraints

- Keep MIT licensing and UCI Iris CC BY 4.0 attribution intact.
- Keep `moon.mod` at version `0.4.0` unless a public API release requires a version bump.
- Preserve the three-platform workflow and generated-interface normalization.
- Target at least 4,000 production/example MoonBit lines and at least 4,600 effective lines including tests, without counting `_build` artifacts.
