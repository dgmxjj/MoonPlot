# OSC2026 Acceptance Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make MoonPlot reproducibly buildable, runnable, documented, licensed, and CI-validated for the OSC2026 pre-acceptance feedback.

**Architecture:** Keep the existing package boundaries (`backend`, `chart`, `color`, `coord`, `series`) and strengthen behavior through black-box tests. Use the community workflow shape with official MoonBit installers, all-target check/build/test, formatter/interface drift checks, and explicit native compiler prerequisites for three operating systems.

**Tech Stack:** MoonBit 0.10.3-compatible module format, Moon CLI, GitHub Actions, SVG/Canvas backends, MIT license.

---

### Task 1: Establish a clean, formatted baseline

**Files:**
- Modify: `moon.mod`, all tracked `moon.pkg` files under `src/` and `examples/`
- Create: tracked `pkg.generated.mbti` files produced by `moon info`

- [ ] **Step 1: Format the repository with the installed Moon toolchain.**

Run `moon fmt` from the module root. Expected: exit code 0 and only canonical MoonBit formatting changes.

- [ ] **Step 2: Generate public interfaces.**

Run `moon info`. Expected: exit code 0 and one `pkg.generated.mbti` per package.

- [ ] **Step 3: Verify the baseline after formatting.**

Run `moon check --target all`, `moon test --target all`, and `moon build --target all`. Expected: no diagnostics and all non-native targets pass; native availability is recorded separately if the local host lacks a C compiler.

### Task 2: Add regression tests for required chart behavior

**Files:**
- Modify: `src/backend/canvas.mbt`
- Create: `src/backend/canvas_test.mbt`
- Modify: `src/series/bar.mbt`, `src/series/scatter.mbt`
- Create: `src/series/series_test.mbt`
- Modify: `src/coord/scale_test.mbt`, `src/chart/svg_test.mbt`

- [ ] **Step 1: Write failing tests for Canvas command generation, empty polygons, text escaping, Bar zero/negative values, Scatter styles, and scale boundaries.**

Run the focused tests and confirm they fail for the missing or incorrect behavior, not because of a test syntax error.

- [ ] **Step 2: Implement the smallest backend/series fixes that satisfy those tests.**

Preserve the existing public package boundaries and keep the APIs declarative and backend-agnostic.

- [ ] **Step 3: Run focused and full tests.**

Run `moon test src/backend`, `moon test src/series`, `moon test src/coord`, `moon test src/chart`, and `moon test --target all`. Expected: all tests pass.

### Task 3: Make examples executable and documentation reproducible

**Files:**
- Modify: `README.md`, `docs/API.md`, `docs/ARCHITECTURE.md`
- Modify: `examples/basic_line/main.mbt`, `examples/basic_bar/main.mbt`
- Modify: `Makefile`, `.gitignore`
- Delete: `task.md` (its historical plaintext credential must not remain in the repository)

- [ ] **Step 1: Replace WIP snippets with verified install, run, API, output, scope, and contribution instructions.**

Document exact commands: `moon update`, `moon check --target all`, `moon build --target all`, `moon test --target all`, and `moon run examples/basic_line` / `moon run examples/basic_bar`.

- [ ] **Step 2: Make examples write deterministic SVG artifacts.**

Use a small checked-in runner convention so each example can be run directly and its SVG output can be redirected or saved without undocumented assumptions.

- [ ] **Step 3: Verify documentation commands and generated output.**

Run both example packages and validate the output contains an SVG root plus the expected series-specific primitives.

### Task 4: Replace CI with the community-compatible three-platform workflow

**Files:**
- Create: `.github/workflows/test.yml`
- Delete: `.github/workflows/ci.yml`

- [ ] **Step 1: Add official installer and platform prerequisites.**

Use the official Unix/PowerShell installers, Linux/macOS C dependencies, and the Windows MSYS2 UCRT64 GCC/OpenSSL setup used by the reference workflow.

- [ ] **Step 2: Add complete validation jobs.**

Run `moon version --all`, `moon update`, `moon check --target all`, `moon build --target all`, `moon test --target all`, `moon fmt --check`, `moon info`, and `git diff --exit-code`.

- [ ] **Step 3: Validate workflow syntax and local command parity.**

Check YAML structure locally and run every non-platform-specific command from the workflow in the worktree.

### Task 5: Perform OSC2026 self-review and publish only verified changes

**Files:**
- Modify: `moon.mod` if registry metadata requires the canonical version bump
- Modify: `README.md` if final self-review identifies missing links or scope wording

- [ ] **Step 1: Audit repository structure, README, license, default branch, history, source scale, and credential leaks.**

Use `git ls-files`, `git log`, `git remote`, `git symbolic-ref`, Moon source counts, and a repository-wide secret-pattern scan. Expected: exactly the creator identity is used for future pushes, no plaintext credentials remain, and the default branch is `main`.

- [ ] **Step 2: Commit the complete change set with a semantic message.**

Run the full verification suite again before committing.

- [ ] **Step 3: Push the verified commit to GitHub main, synchronize GitLink main as the sole creator identity, and publish the new Mooncakes version.**

Record remote results and any service-side limitation without placing credentials in remotes, files, or logs.
