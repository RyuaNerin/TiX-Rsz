#!/bin/sh

. ./var.sh

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
    ${MINGW_PACKAGE_PREFIX}-meson \
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

# clear
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/bin"
mkdir -p "${BUILD_DIR}/src"

####################################################################################################
# orc
cd "${BUILD_DIR}/src"

wget "${ORC_TAR}"
echo "${ORC_TAR_HASH} *${ORC_TAR_NAME}" | sha256sum -c -
tar Jxf "${ORC_TAR_NAME}" -C "${BUILD_DIR}/src"

cd "${BUILD_DIR}/src/${ORC_DIR}"
for i in ${BASE_DIR}/patches/orc*.patch; do
    patch -l -p1 --forward < "$i"
done
${MINGW_PREFIX}/bin/meson \
    --buildtype=release \
    --strip \
    --libdir='lib' \
    --includedir='include' \
    -Ddefault_library=static \
    -Dbenchmarks=disabled \
    -Dexamples=disabled \
    -Dgtk_doc=disabled \
    -Dtests=disabled \
    -Dauto_features=enabled \
    "${BUILD_DIR}/src/${ORC_DIR}-build"

cd "${BUILD_DIR}/src/${ORC_DIR}-build"
ninja
DESTDIR="${BUILD_DIR}" ninja install

####################################################################################################
# libvips
cd "${BUILD_DIR}/src"

wget "${VIPS_TAR}"
echo "${VIPS_HASH} *${VIPS_TAR_NAME}" | sha256sum -c -
tar xzf "${VIPS_TAR_NAME}" -C "${BUILD_DIR}/src"

cd "${BUILD_DIR}/src/${VIPS_DIR}"
for i in ${BASE_DIR}/patches/libvips*.patch; do
    patch -l -p1 --forward < "$i"
done
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
    --without_poppler \
    lt_cv_deplibs_check_method="pass_all"

make ${MAKE_JOBS}
make install

####################################################################################################

cd "${BASE_DIR}/src"
make clean
make ${MAKE_JOBS}

cd "${BASE_DIR}/test"
make clean
make ${MAKE_JOBS}
