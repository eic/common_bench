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
## - DETECTOR_PREFIX:  prefix for the detector definition repositories
## - DETECTOR_PATH:    full path for the detector definitions
##                     this is the same as ${LOCAL_PREFIX}/share/${DETECTOR}

if [ -n "${LOCAL_PREFIX}" ] ; then 
  source .local/bin/env.sh
else
  source ${LOCAL_PREFIX}/bin/env.sh
fi
./${LOCAL_PREFIX}/bin/print_env.sh


# this is like git clone, but allows to fetch any reference, including by git commit SHA
function fetchgit() {
  local path=$1
  local ref=$2
  local uri=$3
  mkdir ${path}
  git -C "${path}" init
  git -C "${path}" remote add origin "${uri}"
  git -C "${path}" fetch origin "${ref}"
  git -C "${path}" checkout "${ref}"
}


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

#if [ "${DETECTOR}" == "epic" ] ; then 
if [ -n "${DETECTOR_DEPLOY_TOKEN_USERNAME:-}" -a -n "${DETECTOR_DEPLOY_TOKEN_PASSWORD:-}" ]; then
  DEPLOY_TOKEN="${DETECTOR_DEPLOY_TOKEN_USERNAME}:${DETECTOR_DEPLOY_TOKEN_PASSWORD}@"
  echo "Deploy token for ${DETECTOR_DEPLOY_TOKEN_USERNAME} is masked in the next line."
else
  DEPLOY_TOKEN=""
fi

echo "fetchgit ${DETECTOR} ${DETECTOR_VERSION} ${DETECTOR_REPOSITORYURL:-https://eicweb.phy.anl.gov/EIC/detectors/${DETECTOR}.git}"
fetchgit ${DETECTOR} ${DETECTOR_VERSION} ${DETECTOR_REPOSITORYURL:-https://${DEPLOY_TOKEN}eicweb.phy.anl.gov/EIC/detectors/${DETECTOR}.git}
if [ -f "${DETECTOR}/requirements.txt" ] ; then
  python -m pip install -r ${DETECTOR}/requirements.txt
fi

rm -rf "${DETECTOR}/.git"
popd

if [ "${BEAMLINE}" ]; then 
  pushd ${DETECTOR_PREFIX}
  ## We need an up-to-date copy of the detector
  ## start clean to avoid issues...
  if [ -d "${BEAMLINE}" ]; then
    echo "cleaning up ${BEAMLINE}" 
    mv "${BEAMLINE}" "$(mktemp)-${BEAMLINE}"
  fi

  echo "Fetching ${BEAMLINE}"

  if [ -n "${BEAMLINE_DEPLOY_TOKEN_USERNAME:-}" -a -n "${BEAMLINE_DEPLOY_TOKEN_PASSWORD:-}" ]; then
    DEPLOY_TOKEN="${BEAMLINE_DEPLOY_TOKEN_USERNAME}:${BEAMLINE_DEPLOY_TOKEN_PASSWORD}@"
    echo "Deploy token for ${BEAMLINE_DEPLOY_TOKEN_USERNAME} is masked in the next line."
  else
    DEPLOY_TOKEN=""
  fi
  echo "fetchgit ${BEAMLINE} ${BEAMLINE_VERSION} ${BEAMLINE_REPOSITORYURL:-https://eicweb.phy.anl.gov/EIC/detectors/${BEAMLINE}.git}"
  fetchgit ${BEAMLINE} ${BEAMLINE_VERSION} ${BEAMLINE_REPOSITORYURL:-https://${DEPLOY_TOKEN}eicweb.phy.anl.gov/EIC/detectors/${BEAMLINE}.git}
  [[ "$?" == "0" ]]  ||  exit 1
  rm -rf "${BEAMLINE}/.git"
  popd

  #echo "ln -s -f ${BEAMLINE} ${DETECTOR}/${BEAMLINE} " 
  #ln -s -f ${BEAMLINE} ${DETECTOR}/${BEAMLINE}
  #[[ "$?" == "0" ]]  ||  exit 1

  mkdir -p ${DETECTOR_PREFIX}/${BEAMLINE}_build
  pushd ${DETECTOR_PREFIX}/${BEAMLINE}_build
  cmake ${DETECTOR_PREFIX}/${BEAMLINE} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 -DCENTRAL_DETECTOR=${DETECTOR} && make -j$(($(nproc)/4+1)) install || exit 1
  popd
  rm -rf ${DETECTOR_PREFIX}/${BEAMLINE}_build

fi


## =============================================================================
## Step 2: Compile and install the detector definition
echo "Building and installing the ${DETECTOR} package"

mkdir -p ${DETECTOR_PREFIX}/${DETECTOR}_build
pushd ${DETECTOR_PREFIX}/${DETECTOR}_build
cmake ${DETECTOR_PREFIX}/${DETECTOR} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 && make -j$(($(nproc)/4+1)) install || exit 1
popd
rm -rf ${DETECTOR_PREFIX}/${DETECTOR}_build

## =============================================================================
## Step 3: That's all!
echo "Detector build/install complete!"
