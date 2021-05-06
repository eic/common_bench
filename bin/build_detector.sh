#!/bin/bash

## =============================================================================
## Build and install the JUGGLER_DETECTOR detector package into our local prefix
## =============================================================================

## make sure we launch this script from the project root directory
#PROJECT_ROOT="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/..
#pushd ${PROJECT_ROOT}

## =============================================================================
## Load the environment variables. To build the detector we need the following
## variables:
##
## - JUGGLER_DETECTOR: the detector package we want to use for this benchmark
## - LOCAL_PREFIX:     location where local packages should be installed
## - LOCAL_DATA_PATH:  local storage for pipeline jobs
## - DETECTOR_PREFIX:  prefix for the detector definitions 
## - DETECTOR_PATH:    full path for the detector definitions
##                     this is the same as ${DETECTOR_PREFIX}/${JUGGLER_DETECTOR}
##
## You can read options/env.sh for more in-depth explanations of the variables
## and how they can be controlled.
source $(dirname "$0")/env.sh

## =============================================================================
## Step 1: download/update the detector definitions (if needed)
pushd ${DETECTOR_PREFIX}

## We need an up-to-date copy of the detector
## start clean to avoid issues...
if [ -d "${JUGGLER_DETECTOR}" ]; then
  echo "cleaning up ${JUGGLER_DETECTOR}" 
  mv "${JUGGLER_DETECTOR}" /tmp/.
fi
echo "Fetching ${JUGGLER_DETECTOR}"
git clone -b ${JUGGLER_DETECTOR_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/detectors/${JUGGLER_DETECTOR}.git
[[ -n "$?" ]]  ||  exit 1
rm -rf "${JUGGLER_DETECTOR}/.git"

## We need an up-to-date copy of the detector
## start clean to avoid issues...
if [ -d "${BEAMLINE_CONFIG}" ]; then
  echo "cleaning up ${BEAMLINE_CONFIG}" 
  mv "${BEAMLINE_CONFIG}" /tmp/.
fi
echo "Fetching ${BEAMLINE_CONFIG}"
echo "git clone -b ${BEAMLINE_CONFIG_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/detectors/${BEAMLINE_CONFIG}.git"
git clone -b ${BEAMLINE_CONFIG_VERSION} --depth 1 https://eicweb.phy.anl.gov/EIC/detectors/${BEAMLINE_CONFIG}.git
[[ -n "$?" ]]  ||  exit 1
rm -rf "${BEAMLINE_CONFIG}/.git"

## We also need an up-to-date copy of the accelerator. For now this is done
## manually. Down the road we could maybe automize this with cmake
if [ -d accelerator ]; then
  echo "cleaning up accelerator"
  mv accelerator /tmp/.
fi
echo "Fetching accelerator"
git clone --depth 1 https://eicweb.phy.anl.gov/EIC/detectors/accelerator.git
[[ -n "$?" ]]  ||  exit 1
rm -rf "accelerator/.git"

## Now symlink the accelerator definition into the detector definition
echo "Linking accelerator definition into detector definition"
ln -s -f ${DETECTOR_PREFIX}/accelerator/eic ${DETECTOR_PATH}/eic
[[ -n "$?" ]]  ||  exit 1
ln -s -f ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}/${BEAMLINE_CONFIG} ${DETECTOR_PATH}/${BEAMLINE_CONFIG}
[[ -n "$?" ]]  ||  exit 1

popd
## =============================================================================
## Step 2: Compile and install the detector definition
echo "Building and installing the ${JUGGLER_DETECTOR} package"

mkdir -p ${DETECTOR_PREFIX}/${JUGGLER_DETECTOR}_build
pushd ${DETECTOR_PREFIX}/${JUGGLER_DETECTOR}_build
cmake ${DETECTOR_PATH} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 && make -j30 install || exit 1
popd
rm -rf ${DETECTOR_PREFIX}/${JUGGLER_DETECTOR}_build

mkdir -p ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}_build
pushd ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}_build
cmake ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 && make -j30 install || exit 1
popd
rm -rf ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}_build



## =============================================================================
## Step 3: That's all!
echo "Detector build/install complete!"
