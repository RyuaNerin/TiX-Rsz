#!/bin/sh

. ./var.sh

# CLEAR
rm -rf vips-*

pacman -Sy --needed \
    autoconf \
    automake-wrapper \
    git \
    libtool \
    make \
    patch \
    \
    ${MINGW_PACKAGE_PREFIX}-gcc \
    ${MINGW_PACKAGE_PREFIX}-gobject-introspection \
    ${MINGW_PACKAGE_PREFIX}-pkg-config \
    \
    ${MINGW_PACKAGE_PREFIX}-cairo \
    ${MINGW_PACKAGE_PREFIX}-cfitsio \
    ${MINGW_PACKAGE_PREFIX}-expat \
    ${MINGW_PACKAGE_PREFIX}-fftw \
    ${MINGW_PACKAGE_PREFIX}-fontconfig \
    ${MINGW_PACKAGE_PREFIX}-giflib \
    ${MINGW_PACKAGE_PREFIX}-glib2 \
    ${MINGW_PACKAGE_PREFIX}-gobject-introspection-runtime \
    ${MINGW_PACKAGE_PREFIX}-imagemagick \
    ${MINGW_PACKAGE_PREFIX}-lcms2 \
    ${MINGW_PACKAGE_PREFIX}-libavif \
    ${MINGW_PACKAGE_PREFIX}-libde265 \
    ${MINGW_PACKAGE_PREFIX}-libgsf \
    ${MINGW_PACKAGE_PREFIX}-libheif \
    ${MINGW_PACKAGE_PREFIX}-libimagequant \
    ${MINGW_PACKAGE_PREFIX}-libjpeg-turbo \
    ${MINGW_PACKAGE_PREFIX}-libpng \
    ${MINGW_PACKAGE_PREFIX}-librsvg \
    ${MINGW_PACKAGE_PREFIX}-libtiff \
    ${MINGW_PACKAGE_PREFIX}-libwebp \
    ${MINGW_PACKAGE_PREFIX}-opencl-icd-git \
    ${MINGW_PACKAGE_PREFIX}-openexr \
    ${MINGW_PACKAGE_PREFIX}-orc \
    ${MINGW_PACKAGE_PREFIX}-pango \
    ${MINGW_PACKAGE_PREFIX}-pkg-config \
    ${MINGW_PACKAGE_PREFIX}-poppler \
    ${MINGW_PACKAGE_PREFIX}-zlib

( \
    wget https://github.com/libvips/libvips/releases/download/${VIPS_TAG}/${VIPS_TAR_NAME} && \
    echo "${VIPS_TAR_HASH} *${VIPS_TAR_NAME}" | sha256sum -c - && \
    tar xzf "${VIPS_TAR_NAME}" && \
    cd "${VIPS_DIR}" && \
    for i in ../patches/libvips.patch; do \
        patch -l -p1 --forward < "$i" || true; \
    done && \
    mkdir -p ${VIPS_BIN_DIR} && \
    ./configure \
        --prefix="${VIPS_BIN_DIR}" \
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
        lt_cv_deplibs_check_method="pass_all" && \
    make ${MAKE_JOBS} && \
    make install \
) || exit

( \
    cd src && \
    make clean && \
    make ${MAKE_JOBS} \
) || exit

( \
    cd test && \
    make clean && \
    make ${MAKE_JOBS} \
) || exit
