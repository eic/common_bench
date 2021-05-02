#!/bin/bash

## =============================================================================
## Install common scripts and libraries for benchmarks
## =============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SETUP_DIR="${SCRIPT_DIR}/.."

# Check there is a local install prefix set and create the directory
# structure for the install.

if [[ -n "${LOCAL_PREFIX}" ]]  ; then
  mkdir -p "${LOCAL_PREFIX}/include"
  mkdir -p "${LOCAL_PREFIX}/bin"
  mkdir -p "${LOCAL_PREFIX}/lib"
  mkdir -p "${LOCAL_PREFIX}/share"

  cp -v -r ${SETUP_DIR}/bin/*     "${LOCAL_PREFIX}/bin/."
  cp -v -r ${SETUP_DIR}/include/* "${LOCAL_PREFIX}/include/."
  cp -v -r ${SETUP_DIR}/share/*   "${LOCAL_PREFIX}/share/."

else
  echo "ERROR: LOCAL_PREFIX is not set. This should never happen!!!"
  exit 1
fi

## =============================================================================
echo "common_bench install complete!"
