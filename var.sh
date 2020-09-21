#!/bin/bash

MAKE_JOBS="-j 8"

export BASE_DIR="${PWD}"
export BUILD_DIR="${PWD}/build"

export MINGW_PREFIX=/mingw64

export PATH=${MINGW_PREFIX}/bin:${PATH}
export ACLOCAL_PATH=${MINGW_PREFIX}/share/aclocal:/usr/share/aclocal

export CONFIG_SITE=${MINGW_PREFIX}/etc/config.site

export MINGW_CHOST=x86_64-w64-mingw32
export MINGW_PACKAGE_PREFIX=mingw-w64-x86_64

export PKG_CONFIG_PATH=${BUILD_DIR}/lib/pkgconfig:${MINGW_PREFIX}/lib/pkgconfig:${MINGW_PREFIX}/share/pkgconfig

VIPS_TAR="https://github.com/libvips/libvips/releases/download/v8.10.1/vips-8.10.1.tar.gz"
VIPS_TAR_NAME="vips-8.10.1.tar.gz"
VIPS_TAR_HASH="e089bb4f73e1dce866ae53e25604ea4f94535488a45bb4f633032e1d2f4e2dda"
VIPS_DIR="vips-8.10.1"

ORC_TAR="https://gstreamer.freedesktop.org/src/orc/orc-0.4.31.tar.xz"
ORC_TAR_NAME="orc-0.4.31.tar.xz"
ORC_TAR_HASH="a0ab5f10a6a9ae7c3a6b4218246564c3bf00d657cbdf587e6d34ec3ef0616075"
ORC_DIR="orc-0.4.31"
