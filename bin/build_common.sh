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
  cp -r common_bench/tools/*     "${LOCAL_PREFIX}/bin/."
  cp -r common_bench/util/*     "${LOCAL_PREFIX}/bin/."
  cp -r common_bench/include/* "${LOCAL_PREFIX}/include/."

fi

## We also need an up-to-date copy of the accelerator. For now this is done
## manually. Down the road we could maybe automize this with cmake
if [ -d accelerator ]; then
  echo "cleaning up accelerator"
  rm -rf accelerator
fi
echo "Fetching accelerator"
git clone https://eicweb.phy.anl.gov/EIC/detectors/accelerator.git
#else
#  echo "Updating accelerator"
#  pushd accelerator
#  git pull --ff-only
#  popd
#fi
## Now symlink the accelerator definition into the detector definition
echo "Linking accelerator definition into detector definition"
ln -s -f ${DETECTOR_PREFIX}/accelerator/eic ${DETECTOR_PATH}/eic

## =============================================================================
## Step 2: Compile and install the detector definition
echo "Building and installing the ${JUGGLER_DETECTOR} package"

mkdir -p ${DETECTOR_PREFIX}/build
pushd ${DETECTOR_PREFIX}/build
cmake ${DETECTOR_PATH} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX} -DCMAKE_CXX_STANDARD=17 && make -j30 install || exit 1
cmake ${DETECTOR_PATH} -DCMAKE_INSTALL_PREFIX=${LOCAL_PREFIX}  -DCMAKE_CXX_STANDARD=17  && make -j30 install

## =============================================================================
## Step 3: That's all!
echo "Detector build/install complete!"
