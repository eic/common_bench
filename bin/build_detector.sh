#!/bin/bash

## =============================================================================
## Build and install the DETECTOR detector package into our local prefix
## =============================================================================

## =============================================================================
## Load the environment variables. To build the detector we need the following
## variables:
##
## - DETECTOR: the detector package we want to use for this benchmark
## - LOCAL_PREFIX:     location where local packages should be installed
## - LOCAL_DATA_PATH:  local storage for pipeline jobs
## - DETECTOR_PREFIX:  prefix for the detector definitions 
## - DETECTOR_PATH:    full path for the detector definitions
##                     this is the same as ${DETECTOR_PREFIX}/${DETECTOR}

if [ -n "${LOCAL_PREFIX}" ] ; then 
  source .local/bin/env.sh
else
  source ${LOCAL_PREFIX}/bin/env.sh
fi


## =============================================================================
## Step 1: download/update the detector definitions (if needed)
pushd ${DETECTOR_PREFIX}

## We need an up-to-date copy of the detector
## start clean to avoid issues...

if [ -d "${DETECTOR}" ]; then
  echo "cleaning up ${DETECTOR}" 
  mv "${DETECTOR}" "$(mktemp)-${DETECTOR}"
fi
echo "Fetching ${DETECTOR}"
if [ -n "${DETECTOR_DEPLOY_TOKEN_USERNAME:-}" -a -n "${DETECTOR_DEPLOY_TOKEN_PASSWORD:-}" ]; then
  DEPLOY_TOKEN="${DETECTOR_DEPLOY_TOKEN_USERNAME}:${DETECTOR_DEPLOY_TOKEN_PASSWORD}@"
  echo "Deploy token for ${DETECTOR_DEPLOY_TOKEN_USERNAME} is masked in the next line."
else
  DEPLOY_TOKEN=""
fi
echo "git clone -b ${DETECTOR_VERSION} --depth 1 ${DETECTOR_REPOSITORYURL:-https://eicweb.phy.anl.gov/EIC/detectors/${DETECTOR}.git}"
git clone -b ${DETECTOR_VERSION} --depth 1 ${DETECTOR_REPOSITORYURL:-https://${DEPLOY_TOKEN}eicweb.phy.anl.gov/EIC/detectors/${DETECTOR}.git}
if [ -f "${DETECTOR}/requirements.txt" ] ; then
  python -m pip install -r ${DETECTOR}/requirements.txt
fi
rm -rf "${DETECTOR}/.git"

## We need an up-to-date copy of the detector
## start clean to avoid issues...
if [ -d "${BEAMLINE_CONFIG}" ]; then
  echo "cleaning up ${BEAMLINE_CONFIG}" 
  mv "${BEAMLINE_CONFIG}" "$(mktemp)-${BEAMLINE_CONFIG}"
fi
echo "Fetching ${BEAMLINE_CONFIG}"
if [ -n "${BEAMLINE_CONFIG_DEPLOY_TOKEN_USERNAME:-}" -a -n "${BEAMLINE_CONFIG_DEPLOY_TOKEN_PASSWORD:-}" ]; then
  DEPLOY_TOKEN="${BEAMLINE_CONFIG_DEPLOY_TOKEN_USERNAME}:${BEAMLINE_CONFIG_DEPLOY_TOKEN_PASSWORD}@"
  echo "Deploy token for ${BEAMLINE_CONFIG_DEPLOY_TOKEN_USERNAME} is masked in the next line."
else
  DEPLOY_TOKEN=""
fi
echo "git clone -b ${BEAMLINE_CONFIG_VERSION} --depth 1 ${BEAMLINE_REPOSITORYURL:-https://eicweb.phy.anl.gov/EIC/detectors/${BEAMLINE_CONFIG}.git}"
git clone -b ${BEAMLINE_CONFIG_VERSION} --depth 1 ${BEAMLINE_REPOSITORYURL:-https://${DEPLOY_TOKEN}eicweb.phy.anl.gov/EIC/detectors/${BEAMLINE_CONFIG}.git}
[[ "$?" == "0" ]]  ||  exit 1
rm -rf "${BEAMLINE_CONFIG}/.git"

## We also need an up-to-date copy of the accelerator. For now this is done
## manually. Down the road we could maybe automize this with cmake
if [ -d accelerator ]; then
  echo "cleaning up accelerator"
  mv "accelerator" "$(mktemp)-accelerator"
fi
echo "Fetching accelerator"
git clone --depth 1 https://eicweb.phy.anl.gov/EIC/detectors/accelerator.git
[[ "$?" == "0" ]]  ||  exit 1
rm -rf "accelerator/.git"

## Now symlink the accelerator definition into the detector definition
echo "Linking accelerator definition into detector definition"
ln -s -f ${DETECTOR_PREFIX}/accelerator/eic ${DETECTOR_PATH}/eic
[[ "$?" == "0" ]]  ||  exit 1
ln -s -f ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}/${BEAMLINE_CONFIG} ${DETECTOR_PATH}/${BEAMLINE_CONFIG}
[[ "$?" == "0" ]]  ||  exit 1

popd
## =============================================================================
## Step 2: Compile and install the detector definition
echo "Building and installing the ${DETECTOR} package"

mkdir -p ${DETECTOR_PREFIX}/${DETECTOR}_build
pushd ${DETECTOR_PREFIX}/${DETECTOR}_build
cmake ${DETECTOR_PATH} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 && make -j$(($(nproc)/4+1)) install || exit 1
popd
rm -rf ${DETECTOR_PREFIX}/${DETECTOR}_build

mkdir -p ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}_build
pushd ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}_build
cmake ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 && make -j$(($(nproc)/4+1)) install || exit 1
popd
rm -rf ${DETECTOR_PREFIX}/${BEAMLINE_CONFIG}_build



## =============================================================================
## Step 3: That's all!
echo "Detector build/install complete!"
