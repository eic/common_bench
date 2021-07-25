[TOC]

# Common Benchmark Code

## Overview

Code common to:
 - `detector_benchmarks`
 - `reconstruction_benchmarks`
 - `physics_benchmarks`


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


