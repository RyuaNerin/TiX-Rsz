#!/bin/sh

mkdir "$2"
cd "$2"
"${MINGW_PREFIX}/bin/cmake.exe" \
    -DSKIP_BUILD_EXAMPLES=ON \
    -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
    -DBUILD_STATIC_LIBS=ON \
    -DBUILD_SHARED_LIBS=OFF \
    "$1"

CC=${CC} make ${MAKE_JOBS}
make install
