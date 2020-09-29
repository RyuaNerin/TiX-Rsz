#!/bin/sh

cd "$1"
./configure \
    --prefix="${BUILD_DIR}" \
    --build=${MINGW_CHOST} \
    --host=${MINGW_CHOST} \
    --target=${MINGW_CHOST} \
    --enable-static \
    --disable-shared \
    --enable-debug=no \
    --disable-introspection \
    --disable-deprecated \
    --without-openslide \
    --without-pdfium \
    --without-cfitsio \
    --without-OpenEXR \
    --without-nifti \
    --without-matio \
    --without-ppm \
    --without-analyze \
    --without-radiance \
    --without-imagequant \
    lt_cv_deplibs_check_method="pass_all"

make ${MAKE_JOBS}
make install
