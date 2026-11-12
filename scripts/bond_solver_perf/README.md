# Bond solver verification and performance

This directory keeps one benchmark that calls the current public solver directly.
It does not generate, slice, or patch production source. Whole-request time includes
preparation, exact search, post-proof candidate collection and public conversion;
manual score/COST/identity checks and witness hashing run outside the timer.

## Current benchmark

Run from the repository root with an isolated, readable `APP_PATH` containing the
required game data and test configuration:

```sh
flutter test scripts/bond_solver_perf/benchmark.dart --no-pub --dart-define=APP_PATH=/tmp/bond-probe-verification/data --reporter expanded
```

Fixtures cover ordinary 3/5/6-position requests and a constructed six-position
Grand request. The default completes the proof with one candidate, two warmups
and five samples. Use `BOND_BENCH_CANDIDATES=25` or `100` to measure post-proof
collection. `BOND_BENCH_MAX_NODES=400` instead enables an explicit evaluation
budget; an interrupted request is not a completed-search timing. Other controls:
`BOND_BENCH_WARMUPS` and `BOND_BENCH_REPEATS`.

Each `BENCH` line records duration, route, evaluations, proof, score/COST,
candidate count and an ordered witness SHA-256. Compare the same data, SDK,
platform, options and source snapshots; preserve all samples and separate
profiling from timing. Process RSS includes the dataset/runtime and is not
solver-only peak memory. These synchronous JIT measurements do not include data
loading, worker dispatch or UI rendering, and do not replace device/AOT tests.

## Regular algorithm regression

Core CE identity matching/cache, source upper bounds and exact ID assignment are
normal Dart modules. The regular suite imports them directly:

```sh
flutter test test/app/modules/bond/solver --no-pub --dart-define=APP_PATH=/tmp/bond-probe-verification/data
```

The same deterministic algorithm cases also run without Flutter or game data:

```sh
dart run test/app/modules/bond/solver/ce_algorithm_cases.dart
dart compile js test/app/modules/bond/solver/ce_algorithm_cases.dart -o /tmp/bond-ce-algorithms.js
node /tmp/bond-ce-algorithms.js
```

These checks include independent exhaustive matching/assignment, canonical
witnesses, forced polynomial matching, Hall-subset failure, zero COST and 31-bit
word boundaries, immutable success/failure caches and saturation, lossless JS
keys, and legal source completions with empty/free equipment. They use the same
implementation as production; no extraction templates are required. Pure JS
checks are not Flutter Web UI tests.

## Historical evidence

- [Current delivery, remaining candidates and restart steps](../../docs/context/bond-solver/optimization_plan.md)
- [Execution record and limitations](../../docs/context/bond-solver/optimization_progress.md)
- [Original JSON evidence](../../docs/context/bond-solver/performance-evidence/)
- [Historical sources/tools archive](../../docs/context/bond-solver/performance_history_2026-11-08.tar.gz)
- [Archive file hashes and source base](../../docs/context/bond-solver/performance_history_manifest.json)

The archive preserves all former templates, generators, patches, runners and
results, plus the matching pre-extraction solver/test snapshot. Before archiving,
the top-F type deletion, pre-stream/pre-probe routing substitutions and DP profile
marker were repaired; all four generated copies passed analysis and actual
Flutter fixture runs. These are stage-specific artifacts, not tools for the current module structure.
Only the four repaired generators were revalidated against the archived
pre-extraction snapshot; older experiments may require their own measured source
versions and are not re-certified as a set. They are retained for historical
inspection, not daily testing.

To inspect without overwriting the checkout:

```sh
mkdir -p /tmp/bond-performance-history
tar -xzf docs/context/bond-solver/performance_history_2026-11-08.tar.gz -C /tmp/bond-performance-history
```

The archive is a source overlay, not a standalone Flutter checkout. Executing its
tools requires an isolated full project at the recorded base with the archived
source overlay, matching SDK/dependencies and dataset. Never restore it over the
working source just to reproduce a benchmark. Older JSON source fingerprints and
10/24 timings must not be attributed to the current implementation or mixed with
the 11/08 dataset.

Documentation/evidence under `docs/` follows the existing local ignore rule and
is not guaranteed to exist in a clean checkout. The business
[design](../../lib/app/modules/bond/solver/design.md) stays in its original location.
