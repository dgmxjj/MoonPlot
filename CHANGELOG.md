# Changelog

## 0.5.0 - 2026-08-15

- Added table profiling, stable grouped numeric summaries, and two-dimensional numeric pivots.
- Added linear regression, residual/MSE diagnostics, z-scores, standard error, and autocorrelation.
- Added reusable area, range-band, box-plot, heatmap, and named dashboard panel APIs.
- Added an independently testable advanced report example combining profiling, grouping, regression, and heatmap rendering.
- Expanded boundary tests across empty, ragged, constant, reversed, negative, and invalid inputs.

## 0.3.0 - 2026-08-07

- Added all-target chart regression tests for Canvas, SVG, Bar, Scatter and scale boundaries.
- Added `ChartLayout`, adaptive legend spacing, positive-size small-canvas clamping and `set_show_grid`.
- Corrected negative-value bar rectangles and escaped SVG/Canvas text output.
- Replaced the pre-acceptance WIP README with reproducible install, run, API, scope and reference documentation.
- Replaced CI with the three-platform official-installer workflow and added build validation.

## 0.4.0 - 2026-08-12

- Added portable CSV parsing with quoted fields, numeric-column conversion and row-level errors.
- Added reusable numeric statistics: summaries, quantiles, histograms, normalization, windows, correlation, robust outliers and deterministic resampling.
- Added responsive `PanelGrid`, wrapping `LegendLayout`, categorical color palettes and series bounds/configuration helpers.
- Added UCI Iris benchmark subset, throughput/latency regression fixture, executable benchmark example and reproducibility documentation.
- Fixed MoonBit 0.10.3 executable package configuration by using `options(is_main: true)`.
