#!/bin/bash

## =============================================================================
## Build and install common scripts and libraries for benchmarks
## =============================================================================

## make sure we launch this script from the project root directory
PROJECT_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/..
pushd ${PROJECT_ROOT}

# Check there is a local install prefix set and create the directory
# structure for the install.

if [[ -n "${LOCAL_PREFIX}" ]]  ; then
  mkdir -p "${LOCAL_PREFIX}/include"
  mkdir -p "${LOCAL_PREFIX}/bin"
  mkdir -p "${LOCAL_PREFIX}/lib"

  #if [ -d common_bench ]; then
  #  echo "cleaning existing common_bench"
  #  rm -rf common_bench
  #fi
  #echo "Fetching common_bench"
  #git clone https://eicweb.phy.anl.gov/EIC/benchmarks/common_bench.git
  cp -r common_bench/bin/*     "${LOCAL_PREFIX}/bin/."
  cp -r common_bench/bin/*     "${LOCAL_PREFIX}/bin/."
  cp -r common_bench/bin/*     "${LOCAL_PREFIX}/bin/."
  cp -r common_bench/include/* "${LOCAL_PREFIX}/include/."

fi

## =============================================================================
echo "common_bench install complete!"
