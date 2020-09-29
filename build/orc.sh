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
    -Ddefault_library=static \
    -Dbenchmarks=disabled \
    -Dexamples=disabled \
    -Dgtk_doc=disabled \
    -Dtests=disabled \
    -Dauto_features=enabled \
    "$2"

cd "$2"
ninja
ninja install
