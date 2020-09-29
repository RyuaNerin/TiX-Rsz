#!/bin/sh

mkdir "$2"
cd "$2"
"${MINGW_PREFIX}/bin/cmake.exe" \
    -Wno-dev \
    -G"MSYS Makefiles" \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
    -DBUILD_STATIC_LIBS=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_CPP_TESTS=OFF \
    -DBUILD_GTK_TESTS=OFF \
    -DBUILD_QT5_TESTS=OFF \
    -DENABLE_CMS=lcms2 \
    -DENABLE_CPP=ON \
    -DENABLE_DCTDECODER=libjpeg \
    -DENABLE_GLIB=ON \
    -DENABLE_GOBJECT_INTROSPECTION=ON \
    -DENABLE_GTK_DOC=OFF \
    -DENABLE_LIBCURL=OFF \
    -DENABLE_LIBOPENJPEG=openjpeg2 \
    -DENABLE_LIBPNG=ON \
    -DENABLE_LIBTIFF=ON \
    -DENABLE_NSS3=ON \
    -DENABLE_QT5=OFF \
    -DENABLE_SPLASH=OFF \
    -DENABLE_UTILS=OFF \
    -DENABLE_ZLIB_UNCOMPRESS=OFF \
    -DENABLE_ZLIB=ON \
    -DSPLASH_CMYK=ON \
    "$1"

CC=${CC} make ${MAKE_JOBS}
make install