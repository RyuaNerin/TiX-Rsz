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
[ -z "${ORC_TAR_NAME}" ] && ORC_TAR_NAME=$(basename ${ORC_TAR})
ORC_DIR=$(basename ${ORC_TAR_NAME} ${ORC_EXT})
if [ ! -f "${BUILD_DIR}/b-${ORC_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${ORC_TAR_NAME}" "${ORC_DIR}" "${ORC_DIR}-build" || true

    wget "${ORC_TAR}" -O "${ORC_TAR_NAME}"
    echo "${ORC_TAR_HASH} *${ORC_TAR_NAME}" | sha256sum -c -
    tar Jxf "${ORC_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${ORC_DIR}"
    find "${BASE_DIR}/patches/" -type f -name 'orc*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i
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
        "${BUILD_DIR}/src/${ORC_DIR}-build"

    cd "${BUILD_DIR}/src/${ORC_DIR}-build"
    ninja
    ninja install

    touch "${BUILD_DIR}/b-${ORC_DIR}"
fi

####################################################################################################
# gdk-pixbuf
[ -z "${GDK_PIXBUF_TAR_NAME}" ] && GDK_PIXBUF_TAR_NAME=$(basename ${GDK_PIXBUF_TAR})
GDK_PIXBUF_DIR=$(basename ${GDK_PIXBUF_TAR_NAME} ${GDK_PIXBUF_EXT})
if [ ! -f "${BUILD_DIR}/b-${GDK_PIXBUF_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${GDK_PIXBUF_TAR_NAME}" "${GDK_PIXBUF_DIR}" "${GDK_PIXBUF_DIR}-build" || true

    wget "${GDK_PIXBUF_TAR}" -O "${GDK_PIXBUF_TAR_NAME}"
    echo "${GDK_PIXBUF_TAR_HASH} *${GDK_PIXBUF_TAR_NAME}" | sha256sum -c -
    tar Jxf "${GDK_PIXBUF_TAR_NAME}" -C "${BUILD_DIR}/src" || true
    tar Jxf "${GDK_PIXBUF_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${GDK_PIXBUF_DIR}"
    find "${BASE_DIR}/patches/" -type f -name 'gdk-pixbuf*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i

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
        "${BUILD_DIR}/src/${GDK_PIXBUF_DIR}-build"

    cd "${BUILD_DIR}/src/${GDK_PIXBUF_DIR}-build"
    ninja
    ninja install

    touch "${BUILD_DIR}/b-${GDK_PIXBUF_DIR}"
fi

####################################################################################################
# poppler-glib
[ -z "${POPPLER_TAR_NAME}" ] && POPPLER_TAR_NAME=$(basename ${POPPLER_TAR})
POPPLER_DIR=$(basename ${POPPLER_TAR_NAME} ${POPPLER_EXT})
if [ ! -f "${BUILD_DIR}/b-${POPPLER_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${POPPLER_TAR_NAME}" "${POPPLER_DIR}" "${POPPLER_DIR}-build" || true

    wget "${POPPLER_TAR}" -O "${POPPLER_TAR_NAME}"
    echo "${POPPLER_TAR_HASH} *${POPPLER_TAR_NAME}" | sha256sum -c -
    tar Jxf "${POPPLER_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${POPPLER_DIR}"
    find "${BASE_DIR}/patches/" -type f -name 'poppler*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i

    mkdir "${BUILD_DIR}/src/${POPPLER_DIR}-build"
    cd "${BUILD_DIR}/src/${POPPLER_DIR}-build"

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
        "${BUILD_DIR}/src/${POPPLER_DIR}"
    CC=${CC} make ${MAKE_JOBS}
    make install

    touch "${BUILD_DIR}/b-${POPPLER_DIR}"
fi

####################################################################################################
# libbrotli
[ -z "${BROTLI_TAR_NAME}" ] && BROTLI_TAR_NAME=$(basename ${BROTLI_TAR})
BROTLI_DIR=$(basename ${BROTLI_TAR_NAME} ${BROTLI_EXT})
if [ ! -f "${BUILD_DIR}/b-${BROTLI_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${BROTLI_TAR_NAME}" "${BROTLI_DIR}" "${BROTLI_DIR}-build" || true

    wget "${BROTLI_TAR}" -O "${BROTLI_TAR_NAME}"
    echo "${BROTLI_TAR_HASH} *${BROTLI_TAR_NAME}" | sha256sum -c -
    tar xzf "${BROTLI_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${BROTLI_DIR}"
    find "${BASE_DIR}/patches/" -type f -name 'brotli*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i

    mkdir "${BUILD_DIR}/src/${BROTLI_DIR}-build"
    cd "${BUILD_DIR}/src/${BROTLI_DIR}-build"

    "${MINGW_PREFIX}/bin/cmake.exe" \
        -G"MSYS Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_SHARED_LIBS=OFF \
        "${BUILD_DIR}/src/${BROTLI_DIR}"
    CC=${CC} make ${MAKE_JOBS}
    make install

    touch "${BUILD_DIR}/b-${BROTLI_DIR}"
fi

####################################################################################################
# libvips
[ -z "${VIPS_TAR_NAME}" ] && VIPS_TAR_NAME=$(basename ${VIPS_TAR})
VIPS_DIR=$(basename ${VIPS_TAR_NAME} ${VIPS_EXT})
if [ ! -f "${BUILD_DIR}/b-${VIPS_DIR}" ]; then
    cd "${BUILD_DIR}/src"

    rm -rf "${VIPS_TAR_NAME}" "${VIPS_DIR}" "${VIPS_DIR}-build" || true

    wget "${VIPS_TAR}" -O "${VIPS_TAR_NAME}"
    echo "${VIPS_TAR_HASH} *${VIPS_TAR_NAME}" | sha256sum -c -
    tar xzf "${VIPS_TAR_NAME}" -C "${BUILD_DIR}/src"

    cd "${BUILD_DIR}/src/${VIPS_DIR}"
    find "${BASE_DIR}/patches/" -type f -name 'libvips*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i
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
fi

####################################################################################################

cd "${BASE_DIR}/src"
make clean
make ${MAKE_JOBS}

cd "${BASE_DIR}/test"
make clean
make ${MAKE_JOBS}
