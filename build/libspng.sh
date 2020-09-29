#!/bin/sh

cd $1
${MINGW_PREFIX}/bin/meson \
    --buildtype=release \
    --strip \
    --prefix "${BUILD_DIR}" \
    --libdir='lib' \
    --bindir='bin' \
    --libexecdir='bin' \
    --includedir='include' \
    -Dstatic_zlib=true \
    $2

cd $2
ninja
ninja install
