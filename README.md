[TOC]

# Common Benchmark Code

## Overview

This repository aims to provide:

1. A common benchmark reporting library used in:
   - [`detector_benchmarks`](https://eicweb.phy.anl.gov/eic/benchmarks/detector_benchmarks/)
   - [`reconstruction_benchmarks`](https://eicweb.phy.anl.gov/eic/benchmarks/reconstruction_benchmarks/)
   - [`physics_benchmarks`](https://eicweb.phy.anl.gov/eic/benchmarks/physics_benchmarks/)
2. A set of tools to manage CI builds and data workflows in other project repos (such as those above).

## Usage

 Bookkeeping of test data to store data of one or more tests in a json file to
 facilitate future accounting.

### Usage Example 1 (single test):

#### define our test

~~~~~~~~~~~~~{.cpp}
common_bench::Test test1{
  {{"name", "example_test"},
    {"title", "Example Test"},
    {"description", "This is an example of a test definition"},
    {"quantity", "efficiency"},
    {"target", "1"}}};
~~~~~~~~~~~~~

#### set pass/fail/error status and return value (in this case .99)

~~~~~~~~~~~~~{.cpp}
test1.pass(0.99)
~~~~~~~~~~~~~

#### write our test data to a json file

~~~~~~~~~~~~~{.cpp}
common_bench::write_test(test1, "test1.json");
~~~~~~~~~~~~~

### Usage Example 2 (multiple tests):

#### Define our tests

~~~~~~~~~~~~~{.cpp}
common_bench::Test test1{{
  {"name", "example_test"},
  {"title", "Example Test"},
  {"description", "This is an example of a test definition"},
  {"quantity", "efficiency"},
  {"target", "1"}}};
common_bench::Test test2{{
  {"name", "another_test"},
  {"title", "Another example Test"},
  {"description", "This is a second example of a test definition"},
  {"quantity", "resolution"},
  {"target", "3."}}};
~~~~~~~~~~~~~

#### set pass/fail/error status and return value (in this case .99)

~~~~~~~~~~~~~{.cpp}
test1.fail(10)
~~~~~~~~~~~~~

#### write our test data to a json file

~~~~~~~~~~~~~{.cpp}
common_bench::write_test({test1, test2}, "test.json");
~~~~~~~~~~~~~

## CI builds and data workflow tools

### Environment Variables

Here we aim to document a coherent set of environment varialbes to pass between CI jobs **and between pipelines**.
The idea is to write as much generic code  as possible, so this can be used by any detector currently being implemented or yet to be defined.

#### The Important Ones

| Variable           | Meaning and use                                              | Examples                                            | Notes                                |
| :---               | :---                                                         | :---                                                | :---                                 |
| `DETECTOR`         | Name of detector and repository                              | `athena` or `epic`                                  |                                      |
| `DETECTOR_VERSION` | Branch or tagged version to use                              | A PR branch name automatically generated from issue | Default typically `main` or `master` |
| `BEAMLINE`         | Optional, name of beamline/interaction region to build first | `ip6` or `ip8`                                      | Not used if undefined                |
| `BEAMLINE_VERSION` | Branch or tagged version to use                              | Same as                                             | Default typically `main` or `master` |

#### Build Strategy

First, let's start with the underlying assumptions: 
 - A "finished" container image will include a completely furnished detector (or detectors) -- from here, the goals is to run all the benchmarks.
 - Development necessitates rebuilding some of the packaged software. Here we need to avoid unintentionally using the container packaged version we want to supplant.
 - This problem persists across CI jobs, triggered pipelines, and working locally.

In the case  


#### Data Flow: Artifacts Vs dedicated storage




### For benchmarks



