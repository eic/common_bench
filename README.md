# Common Benchmark Code

## Overview

This repository provides shared infrastructure for EIC detector and physics benchmarks:

1. **A CI environment setup script** (`bin/env.sh`) sourced by every benchmark job to establish
   a consistent set of environment variables.
2. **A C++ benchmark reporting library** (`include/common_bench/`) used by analysis scripts to
   record pass/fail test results as JSON.
3. **Python and shell utilities** (`bin/`) for compiling ROOT analyses, collecting test results,
   and managing local data directories.

Used by:
- [`detector_benchmarks`](https://github.com/eic/detector_benchmarks)
- [`physics_benchmarks`](https://github.com/eic/physics_benchmarks)

## Environment Setup (`bin/env.sh`)

`bin/env.sh` is sourced early in each CI job. It sets default values for
CI-controlled variables and establishes derived paths.

### Variables set by CI (override defaults)

| Variable              | Default  | Meaning                                                |
| :---                  | :---     | :---                                                   |
| `DETECTOR`            | *(none)* | Detector package name (e.g. `epic`); **required**      |
| `DETECTOR_CONFIG`     | *(none)* | Detector geometry config (e.g. `epic_full`); optional  |
| `DETECTOR_VERSION`    | `main`   | Branch or tag of the detector package                  |
| `BENCHMARK_N_EVENTS`  | `100`    | Number of events for simulation/reconstruction         |
| `BENCHMARK_N_THREADS` | `10`     | Maximum parallel threads/processes per job             |
| `BENCHMARK_RNG_SEED`  | `1`      | Random seed for reproducibility                        |

### Variables derived by `env.sh`

| Variable             | Value                                          | Meaning                                    |
| :---                 | :---                                           | :---                                       |
| `LOCAL_PREFIX`       | `$PWD/.local`                                  | Prefix for files installed during the benchmark |
| `DETECTOR_PATH`      | `$LOCAL_PREFIX/share/$DETECTOR`                | Root path to installed detector XML files  |
| `ROOT_BUILD_DIR`     | `$LOCAL_PREFIX/root_build`                     | ROOT ACLiC build output directory          |
| `ROOT_INCLUDE_PATH`  | `$LOCAL_PREFIX/include:...`                    | Additional include paths for ROOT/ACLiC    |
| `ROOT_MAX_THREADS`   | `$BENCHMARK_N_THREADS`                         | Caps ROOT implicit multi-threading         |
| `JUGGLER_N_EVENTS`   | `$BENCHMARK_N_EVENTS`                          | Alias for legacy script compatibility      |
| `JUGGLER_N_THREADS`  | `$BENCHMARK_N_THREADS`                         | Alias for legacy script compatibility      |
| `JUGGLER_RNG_SEED`   | `$BENCHMARK_RNG_SEED`                          | Alias for legacy script compatibility      |
| `LOCAL_DATA_PATH`    | `/scratch/${CI_PROJECT_NAME}_${CI_PIPELINE_ID}` if writable, otherwise `$PWD/scratch/${CI_PROJECT_NAME}_${CI_PIPELINE_ID}` | Scratch storage shared across pipeline jobs, with a working-directory fallback for local runs or constrained runners |

## Benchmark Reporting Library (`include/common_bench/`)

The `common_bench::Test` class and `write_test()` helper write pass/fail/error test results
to JSON files for downstream aggregation by `bin/collect_tests.py` and `bin/collect_benchmarks.py`.

Dependencies: [`{fmt}`](https://github.com/fmtlib/fmt), [`nlohmann/json`](https://github.com/nlohmann/json)
(both available in the EIC software stack).

### Example: single test

```cpp
#include "common_bench/benchmark.h"

common_bench::Test test{{
  {"name",        "my_efficiency"},
  {"title",       "Tracking efficiency"},
  {"description", "Fraction of truth tracks reconstructed"},
  {"quantity",    "efficiency"},
  {"target",      "0.9"},
  {"value",       "0"}}};

test.pass(0.95);  // or test.fail(0.72) or test.error()
common_bench::write_test(test, "results/my_efficiency.json");
```

### Example: multiple tests

```cpp
common_bench::write_test({test1, test2}, "results/tracking.json");
```

## Utilities (`bin/`)

| Script                 | Purpose                                                              |
| :---                   | :---                                                                 |
| `env.sh`               | CI environment setup — sourced in every job's `before_script`        |
| `compile_analyses.py`  | Compiles ROOT ACLiC analysis scripts for a given benchmark directory |
| `collect_tests.py`     | Collects individual JSON test results into a per-benchmark summary   |
| `collect_benchmarks.py`| Merges all benchmark summaries into a master `results/summary.json`  |
| `mkdir_local_data_link`| Creates `LOCAL_DATA_PATH/<dir>` and symlinks it into the working dir |
| `strict-mode.sh`       | Shell strict-mode boilerplate (`set -Euo pipefail` + trap) for scripts|
| `parse_cmd.sh`         | *(deprecated — pending removal)*                                     |
| `print_env.sh`         | *(deprecated — pending removal)*                                     |


