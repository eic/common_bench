#!/bin/bash

## =============================================================================
## Global configuration variables for the benchmark scripts
## The script defines the following environment variables that are meant to
## be overriden by the Gitlab continuous integration (CI)
##
##  - DETECTOR:                detector package to be used for the benchmark
##  - DETECTOR_CONFIG:         detector package config to be used for the benchmark
##  - DETECTOR_VERSION:        detector package to be used for the benchmark
##  - BENCHMARK_N_EVENTS:      events processed by simulation/reconstruction
##  - BENCHMARK_N_THREADS:     number of threads/processes to spawn in parallel
##  - BENCHMARK_RNG_SEED:      random seed for the RNG
##  - JUGGLER_INSTALL_PREFIX:  location where Juggler (digi/recon) is installed
##
## It also defines the following additional variables for internally usage
##  - LOCAL_PREFIX:           prefix for packages installed during the benchmark
##  - LOCAL_DATA_PATH:        local storage for pipeline jobs
##  - DETECTOR_PREFIX:        prefix for the detector definitions
##  - DETECTOR_PATH:          actual path with the detector definitions
##
## Finally, it makes sure LOCAL_PREFIX and JUGGLER_PREFIX are added to PATH
## and LD_LIBRARY_PATH
## =============================================================================

echo "Setting up the Physics Benchmarks environment"

## =============================================================================
## Default variable definitions, normally these should be set
## by the CI. In case of local development you may want to change these
## in case you would like to modify the detector package or
## number of events to be analyzed during the benchmark

## Detector package to be used during the benchmark process
if [ ! -n  "${DETECTOR}" ] ; then 
  export DETECTOR="epic"
fi

if [ ! -n  "${DETECTOR_CONFIG}" ] ; then
  export DETECTOR_CONFIG="${DETECTOR}_full"
fi

if [ ! -n  "${DETECTOR_VERSION}" ] ; then 
  export DETECTOR_VERSION="main"
fi

if [ ! -n  "${DETECTOR_REPOSITORYURL}" ] ; then
  export DETECTOR_REPOSITORYURL="https://github.com/eic/${DETECTOR}.git"
fi

## Number of events that will be processed by the reconstruction
if [ ! -n  "${BENCHMARK_N_EVENTS}" ] ; then 
  export BENCHMARK_N_EVENTS=100
fi
export JUGGLER_N_EVENTS=${BENCHMARK_N_EVENTS}

## Maximum number of threads or processes a single pipeline should use
## (this is not enforced, but the different pipeline scripts should use
##  this to guide the number of parallel processes or threads they 
##  spawn).
if [ ! -n "${BENCHMARK_N_THREADS}" ]; then
  export BENCHMARK_N_THREADS=10
fi
export JUGGLER_N_THREADS=${BENCHMARK_N_THREADS}

## Random seed for event generation, should typically not be changed for
## reproductability.
if [ ! -n "${BENCHMARK_RNG_SEED}" ]; then
  export BENCHMARK_RNG_SEED=1
fi
export JUGGLER_RNG_SEED=${BENCHMARK_RNG_SEED}

## Install prefix for juggler, needed to locate the Juggler xenv files.
## Also used by the CI as install prefix for other packages where needed.
## You should not have to touch this. Note that for local usage a different 
## prefix structure is automatically used.
if [ ! -n  "${JUGGLER_INSTALL_PREFIX}" ] ; then 
  export JUGGLER_INSTALL_PREFIX="/usr/local"
fi
## Ensure the juggler prefix is an absolute path
export JUGGLER_INSTALL_PREFIX=`realpath ${JUGGLER_INSTALL_PREFIX}`


## Location of local data for pass data from job to job within pipeline.
## Not saved as artifacts.
## Local /scratch directory is presumed to be writable. 
if [ ! -n  "${LOCAL_DATA_PATH}" ] ; then 
  export LOCAL_DATA_PATH="/scratch/${CI_PROJECT_NAME}_${CI_PIPELINE_ID}"
fi
mkdir -p "${LOCAL_DATA_PATH}"
if [ ! -d "${LOCAL_DATA_PATH}" ]; then 
  echo "LOCAL_DATA_PATH (${LOCAL_DATA_PATH}) does not exist!!"
  echo "Creating LOCAL_DATA_PATH=$(pwd)/local_data "
  export LOCAL_DATA_PATH="$(pwd)/local_data"
  mkdir -p "${LOCAL_DATA_PATH}"
fi

## =============================================================================
## Other utility variables that govern how some of the dependent packages
## are built and installed. You should not have to change these.

## local prefix to be used for local storage of packages
## downloaded/installed during the benchmark process
LOCAL_PREFIX=".local"
mkdir -p "${LOCAL_PREFIX}"
export LOCAL_PREFIX=`realpath ${LOCAL_PREFIX}`

## detector prefix: prefix for the detector definitions
export DETECTOR_PREFIX="${LOCAL_PREFIX}/detector"
mkdir -p ${DETECTOR_PREFIX}

## detector path: actual detector definition path
export DETECTOR_PATH="${DETECTOR_PREFIX}/${DETECTOR}"

## build dir for ROOT to put its binaries etc.
export ROOT_BUILD_DIR=$LOCAL_PREFIX/root_build

export ROOT_INCLUDE_PATH=${LOCAL_PREFIX}/include:${ROOT_INCLUDE_PATH}

echo "DETECTOR=${DETECTOR}" >> .env
echo "DETECTOR_CONFIG=${DETECTOR_CONFIG}" >> .env
echo "DETECTOR_VERSION=${DETECTOR_VERSION}" >> .env
echo "DETECTOR_REPOSITORYURL=${DETECTOR_REPOSITORYURL}" >> .env
echo "BENCHMARK_N_EVENTS=${BENCHMARK_N_EVENTS}" >> .env
echo "BENCHMARK_N_THREADS=${BENCHMARK_N_THREADS}" >> .env
echo "BENCHMARK_RNG_SEED=${BENCHMARK_RNG_SEED}" >> .env
echo "JUGGLER_N_EVENTS=${JUGGLER_N_EVENTS}" >> .env
echo "JUGGLER_N_THREADS=${JUGGLER_N_THREADS}" >> .env
echo "JUGGLER_RNG_SEED=${JUGGLER_RNG_SEED}" >> .env
echo "LOCAL_PREFIX=${LOCAL_PREFIX}" >> .env
echo "DETECTOR_PREFIX=${DETECTOR_PREFIX}" >> .env
echo "DETECTOR_PATH=${DETECTOR_PATH}" >> .env
echo "ROOT_BUILD_DIR=${ROOT_BUILD_DIR}" >> .env
echo "ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}" >> .env
echo "LOCAL_DATA_PATH=${LOCAL_DATA_PATH}" >> .env

## =============================================================================
## Setup PATH and LD_LIBRARY_PATH to include our prefixes
echo "Adding JUGGLER_INSTALL_PREFIX and LOCAL_PREFIX to PATH and LD_LIBRARY_PATH"
export PATH=${LOCAL_PREFIX}/bin:${JUGGLER_INSTALL_PREFIX}/bin:${PATH}
export LD_LIBRARY_PATH=${LOCAL_PREFIX}/lib:${JUGGLER_INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH}

# Local field maps
mkdir -p ${LOCAL_DATA_PATH}/fieldmaps
ln -sf ${LOCAL_DATA_PATH}/fieldmaps

## =============================================================================
## That's all!
echo "Environment setup complete."
