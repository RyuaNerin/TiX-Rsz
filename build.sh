#!/bin/sh

on_err() {
    ERROR_CODE=$?
    echo
    echo
    echo "error ${ERROR_CODE}"
    echo "the command executing at the time of the error was"
    echo "${BASH_COMMAND}"
    echo "on line ${BASH_LINENO[0]}"
    exit ${ERROR_CODE}
}
trap on_err ERR

. ./var.sh

pacman -Syq --needed --noconfirm \
    autoconf \
    automake-wrapper \
    git \
    libtool \
    make \
    patch \
    wget \
    \
    ${MINGW_PACKAGE_PREFIX}-cmake \
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
    ${MINGW_PACKAGE_PREFIX}-pango \
    ${MINGW_PACKAGE_PREFIX}-pkg-config \
    ${MINGW_PACKAGE_PREFIX}-zlib

# clear
#rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/bin" || true
mkdir -p "${BUILD_DIR}/src" || true

####################################################################################################
# orc
ORC_TAR_NAME=$(basename ${ORC_TAR})
ORC_DIR=$(basename ${ORC_TAR} ${ORC_EXT})
if [ ! -f "${BUILD_DIR}/b-${ORC_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${ORC_TAR_NAME}" "${ORC_DIR}" "${ORC_DIR}-build" || true

    wget "${ORC_TAR}"
    echo "${ORC_TAR_HASH} *$(basename ${ORC_TAR})" | sha256sum -c -
    tar Jxf "${ORC_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${ORC_DIR}"
    for i in ${BASE_DIR}/patches/orc*.patch; do
        patch -p1 < "$i"
    done
    ${MINGW_PREFIX}/bin/meson \
        --buildtype=release \
        --strip \
        --prefix "${BUILD_DIR}" \
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
    ninja install

    touch "${BUILD_DIR}/b-${ORC_DIR}"
    exit
fi

####################################################################################################
# poppler-glib
#<<'EOF'
POPPLER_TAR_NAME=$(basename ${POPPLER_TAR})
POPPLER_DIR=$(basename ${POPPLER_TAR} ${POPPLER_EXT})
if [ ! -f "${BUILD_DIR}/b-${POPPLER_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${POPPLER_TAR_NAME}" "${POPPLER_DIR}" "${POPPLER_DIR}-build" || true

    wget "${POPPLER_TAR}"
    echo "${POPPLER_TAR_HASH} *$(basename ${POPPLER_TAR})" | sha256sum -c -
    tar Jxf "${POPPLER_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${POPPLER_DIR}"
    for i in ${BASE_DIR}/patches/poppler*.patch; do
        patch -p1 < "$i"
    done

    mkdir "${BUILD_DIR}/src/${POPPLER_DIR}-build"
    cd "${BUILD_DIR}/src/${POPPLER_DIR}-build"

    "${MINGW_PREFIX}/bin/cmake.exe" \
        -Wno-dev \
        -G"MSYS Makefiles" \
        -DCMAKE_BUILD_TYPE=release \
        -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
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
        -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
        -DENABLE_UTILS=OFF \
        -DENABLE_ZLIB_UNCOMPRESS=OFF \
        -DENABLE_ZLIB=ON \
        -DSPLASH_CMYK=ON \
        "${BUILD_DIR}/src/${POPPLER_DIR}"
    CC=${CC} make ${MAKE_JOBS}
    make install

    touch "${BUILD_DIR}/b-${POPPLER_DIR}"
    exit
fi
#EOF

####################################################################################################
# libvips
VIPS_TAR_NAME=$(basename ${VIPS_TAR})
VIPS_DIR=$(basename ${VIPS_TAR} ${VIPS_EXT})
if [ ! -f "${BUILD_DIR}/b-${VIPS_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${VIPS_TAR_NAME}" "${VIPS_DIR}" "${VIPS_DIR}-build" || true

    wget "${VIPS_TAR}"
    echo "${VIPS_TAR_HASH} *$(basename ${VIPS_TAR})" | sha256sum -c -
    tar xzf "${VIPS_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${VIPS_DIR}"
    for i in ${BASE_DIR}/patches/libvips*.patch; do
        patch -p1 < "$i"
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
        lt_cv_deplibs_check_method="pass_all"

    make ${MAKE_JOBS}
    make install

    touch "${BUILD_DIR}/b-${VIPS_DIR}"
    exit
fi

####################################################################################################

cd "${BASE_DIR}/src"
make clean
make ${MAKE_JOBS}

cd "${BASE_DIR}/test"
make clean
make ${MAKE_JOBS}
