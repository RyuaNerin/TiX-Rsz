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
    -Dbuiltin_loaders='jpeg,png,tiff' \
    -Dnative_windows_loaders=true \
    -Ddocs=false \
    -Dman=false \
    -Dgir=false \
    -Dinstalled_tests=false \
    -Djasper=true \
    -Drelocatable=true \
    -Dx11=false \
    "$2"

cd "$2"
ninja
ninja install
