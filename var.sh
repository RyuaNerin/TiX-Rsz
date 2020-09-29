#!/bin/bash

MAKE_JOBS="-j 4"

export BASE_DIR="${PWD}"
export BUILD_DIR="${PWD}/bin"

export MINGW_PREFIX=/mingw64
export MINGW_CHOST=x86_64-w64-mingw32
export MINGW_PACKAGE_PREFIX=mingw-w64-x86_64

export CC="${MINGW_PREFIX}/bin/gcc.exe"
export CXX="${MINGW_PREFIX}/bin/g++.exe"

#export PATH=${MINGW_PREFIX}/bin:${PATH}
export PATH=${BUILD_DIR}/bin:${PATH}
export ACLOCAL_PATH=${BUILD_DIR}/share/acloal

export CONFIG_SITE=${MINGW_PREFIX}/etc/config.site

export PKG_CONFIG_PATH=${BUILD_DIR}/lib/pkgconfig:${BUILD_DIR}/share/lib/pkgconfig
