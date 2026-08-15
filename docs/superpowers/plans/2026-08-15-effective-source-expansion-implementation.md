# Effective Source Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development for each new behavior and superpowers:verification-before-completion before handoff.

**Goal:** Add real data profiling, regression, area-chart, and heatmap capabilities with tests and documentation so effective production MoonBit source exceeds 4,000 lines.

**Architecture:** Extend the existing public `data`, `stats`, and `series` packages. Data and statistics stay pure; renderers use the existing `Backend` and `Scale` abstractions. Examples expose deterministic pipelines that can be run by README commands and tested without filesystem access.

**Tech Stack:** MoonBit 0.10.3-compatible syntax, `moon check/test/build/fmt/info`, SVG and Canvas backends, existing color and coordinate packages.

---

### Task 1: Data profiling

**Files:**
- Create: `src/data/profile.mbt`
- Create: `src/data/profile_test.mbt`
- Modify: `src/data/pkg.generated.mbti` via `moon info`

- [ ] Write tests for numeric/categorical/missing column profiles, empty tables, invalid columns, and deterministic category counts.
- [ ] Run `moon test src/data/profile_test.mbt --target wasm` and observe missing API failures.
- [ ] Implement `ColumnKind`, `ColumnProfile`, `TableProfile`, `CsvTable::profile`, and safe profile helpers.
- [ ] Run the focused tests, then all data-package tests.

### Task 2: Linear regression

**Files:**
- Create: `src/stats/regression.mbt`
- Create: `src/stats/regression_test.mbt`
- Modify: `src/stats/pkg.generated.mbti` via `moon info`

- [ ] Write tests for slope/intercept, prediction, residuals, R², MSE, one-point data, constant x, empty data, and mismatched lengths.
- [ ] Run the focused test to confirm the new API fails before implementation.
- [ ] Implement `LinearRegression` and `NumericSeries::linear_regression` with deterministic zero-denominator handling.
- [ ] Run focused and package-wide tests.

### Task 3: Area and heatmap series

**Files:**
- Create: `src/series/area.mbt`
- Create: `src/series/heatmap.mbt`
- Create: `src/series/advanced_series_test.mbt`
- Modify: `src/series/moon.pkg`
- Modify: `src/series/pkg.generated.mbti` via `moon info`

- [ ] Write tests for area bounds, baseline behavior, empty/negative data, heatmap cell indexing, color interpolation, invalid dimensions, and SVG/Canvas rendering.
- [ ] Run the focused tests and confirm missing constructors/methods fail.
- [ ] Implement backend-generic `AreaSeries` and `HeatmapSeries` with clamped parameters and no out-of-range access.
- [ ] Run focused tests and all existing series/backend/chart tests.

### Task 4: Runnable examples and docs

**Files:**
- Create: `examples/advanced_report/main.mbt`
- Create: `examples/advanced_report/moon.pkg`
- Modify: `README.md`
- Modify: `docs/API.md`
- Modify: `docs/BENCHMARKS.md`
- Modify: `docs/DEVELOPMENT.md`
- Modify: `CHANGELOG.md`

- [ ] Add a deterministic report example using Iris profiling and regression, plus a heatmap output path.
- [ ] Run the example for WASM and verify stable SVG markers.
- [ ] Document scope, API signatures, expected outputs, data provenance, and the embedded-data/WASM trade-off.

### Task 5: Final verification

**Files:**
- Modify: `.github/workflows/test.yml` only if verification exposes a reproducibility gap.
- Modify: generated `.mbti` files through `moon info` normalization.

- [ ] Run `moon fmt --check src examples`, `moon check/build/test --target all --deny-warn`, and the benchmark examples.
- [ ] Run coverage and inspect remaining uncovered branches; add tests for new and previously identified safety branches where practical.
- [ ] Count only tracked `src/**/*.mbt` and `examples/**/*.mbt`, excluding `_build`; verify production/examples exceed 4,000 lines.
- [ ] Run secret scan, Markdown-link scan, `git diff --check`, and author/default-branch checks.
- [ ] Commit, push both remotes, and verify identical `main` SHA and single-author history.
