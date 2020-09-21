#!/bin/bash

MAKE_JOBS="-j 8"

export BUILD_PREFIX="${PWD}/build"

export PATH=/mingw64/bin:${PATH}
export ACLOCAL_PATH=/mingw64/share/aclocal:/usr/share/aclocal

export CONFIG_SITE=/mingw64/etc/config.site

export MINGW_CHOST=x86_64-w64-mingw32
export MINGW_PACKAGE_PREFIX=mingw-w64-x86_64

export PKG_CONFIG_PATH=${BUILD_PREFIX}:/mingw64/lib/pkgconfig:/mingw64/share/pkgconfig

VIPS_TAG="v8.10.1"
VIPS_DIR="vips-8.10.1"
VIPS_TAR_NAME="vips-8.10.1.tar.gz"
VIPS_TAR_HASH="e089bb4f73e1dce866ae53e25604ea4f94535488a45bb4f633032e1d2f4e2dda"
