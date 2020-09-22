#!/bin/bash

MAKE_JOBS="-j 4"

export BASE_DIR="${PWD}"
export BUILD_DIR="${PWD}/build"

export MINGW_PREFIX=/mingw64

export CC="${MINGW_PREFIX}/bin/gcc.exe"
export CXX="${MINGW_PREFIX}/bin/g++.exe"

export PATH=${MINGW_PREFIX}/bin:${PATH}
export ACLOCAL_PATH=${MINGW_PREFIX}/share/aclocal:/usr/share/aclocal

export CONFIG_SITE=${MINGW_PREFIX}/etc/config.site

export MINGW_CHOST=x86_64-w64-mingw32
export MINGW_PACKAGE_PREFIX=mingw-w64-x86_64

export PKG_CONFIG_PATH=${BUILD_DIR}/lib/pkgconfig:${BUILD_DIR}/share/lib/pkgconfig:${MINGW_PREFIX}/lib/pkgconfig:${MINGW_PREFIX}/share/pkgconfig

VIPS_TAR="https://github.com/libvips/libvips/releases/download/v8.10.1/vips-8.10.1.tar.gz"
VIPS_TAR_HASH="e089bb4f73e1dce866ae53e25604ea4f94535488a45bb4f633032e1d2f4e2dda"
VIPS_EXT=".tar.gz"

ORC_TAR="https://gstreamer.freedesktop.org/src/orc/orc-0.4.31.tar.xz"
ORC_TAR_HASH="a0ab5f10a6a9ae7c3a6b4218246564c3bf00d657cbdf587e6d34ec3ef0616075"
ORC_EXT=".tar.xz"

POPPLER_TAR="https://poppler.freedesktop.org/poppler-0.88.0.tar.xz"
POPPLER_TAR_HASH="b4453804e9a5a519e6ceee0ac8f5efc229e3b0bf70419263c239124474d256c7"
POPPLER_EXT=".tar.xz"

alias wget='wget -q --show-progress'
