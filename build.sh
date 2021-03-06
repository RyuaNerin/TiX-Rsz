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

# clear
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/bin" || true
mkdir -p "${BUILD_DIR}/src" || true

X() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.tar.xz)    tar xvJf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "Unable to extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

BUILD() {
    trap on_err ERR

    PACKAGE_NAME=$1
    PACKAGE_SRC_HASH=$2
    PACKAGE_SRC_URL=$3
    PACKAGE_SRC_NAME=$4

    [ -z "${PACKAGE_SRC_NAME}" ] && PACKAGE_SRC_NAME=$(basename ${PACKAGE_SRC_URL})
    PACKAGE_DIR_NAME="$(echo "${PACKAGE_SRC_NAME}" | sed -E 's/\.(tar\.bz2|tar\.gz|tar\.xz|bz2|rar|gz|tar|tbz2|tgz|zip|Z|7z)$//g')"

    if [ ! -f "${BUILD_DIR}/build-${PACKAGE_NAME}" ]; then
        cd "${BUILD_DIR}/src"

        rm -rf "${PACKAGE_SRC_NAME}" "${PACKAGE_DIR_NAME}" "${PACKAGE_DIR_NAME}-build" || true

        wget "${PACKAGE_SRC_URL}" -O "${PACKAGE_SRC_NAME}"
        echo "${PACKAGE_SRC_HASH} *${PACKAGE_SRC_NAME}" | sha256sum -c -
        X "${PACKAGE_SRC_NAME}" || X "${PACKAGE_SRC_NAME}"

        cd "${BUILD_DIR}/src/${PACKAGE_DIR_NAME}"
        find "${BASE_DIR}/patches/" -type f -name "${PACKAGE_NAME}*.patch" -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i

        "${BASE_DIR}/build/${PACKAGE_NAME}.sh" \
            "${BUILD_DIR}/src/${PACKAGE_DIR_NAME}" \
            "${BUILD_DIR}/src/${PACKAGE_DIR_NAME}-build"

        touch "${BUILD_DIR}/build-${PACKAGE_NAME}"
    fi
}

####################################################################################################
BUILD "glib"            "c5a66bf143065648c135da4c943d2ac23cce15690fc91c358013b2889111156c" "https://download.gnome.org/sources/glib/2.66/glib-2.66.0.tar.xz"
BUILD "expat"           "4456e0aa72ecc7e1d4b3368cd545a5eec7f9de5133a8dc37fdb1efa6174c4947" "https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz"

BUILD "orc"             "a66e3d8f2b7e65178d786a01ef61f2a0a0b4d0b8370de7ce134ba73da4af18f0" "https://gstreamer.freedesktop.org/src/orc/orc-0.4.32.tar.xz"

BUILD "libwebp"         "424faab60a14cb92c2a062733b6977b4cc1e875a6398887c5911b3a1a6c56c51" "https://github.com/webmproject/libwebp/archive/v1.1.0.tar.gz"                               "libwebp-1.1.0.tar.gz"

BUILD "libpng"          "daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4" "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz"

BUILD "libspng"         "336856bea0216fe0ddc6cc584be5823cfd3a142e9d90d8e1635d2d2a5241f584" "https://github.com/randy408/libspng/archive/v0.6.1.tar.gz"                                  "libspng-0.6.1.tar.gz"

#BUILD "brotli"          "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46" "https://github.com/google/brotli/archive/v1.0.9.tar.gz"                                     "brotli-1.0.9.tar.gz"

BUILD "libjpeg-turbo"   "b3090cd37b5a8b3e4dbd30a1311b3989a894e5d3c668f14cbc6739d77c9402b7" "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.5.tar.gz"                        "libjpeg-turbo-2.0.5.tar.gz"

BUILD "zlib"            "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff" "https://github.com/madler/zlib/archive/v1.2.11.tar.gz"                                      "zlib-1.2.11.tar.gz"
BUILD "libspng"         "336856bea0216fe0ddc6cc584be5823cfd3a142e9d90d8e1635d2d2a5241f584" "https://github.com/randy408/libspng/archive/v0.6.1.tar.gz"                                  "libspng-0.6.1.tar.gz"

BUILD "libexif"         "75dc5c135c61b5e0b15f3911b4de4b3070dd1a1683b9fc08d9ce3518d54d758d" "https://github.com/libexif/libexif/releases/download/libexif-0_6_22-release/libexif-0.6.22.tar.gz"

BUILD "freetype"        "1543d61025d2e6312e0a1c563652555f17378a204a61e99928c9fcef030a2d8b" "https://download.savannah.gnu.org/releases/freetype/freetype-2.10.2.tar.xz"
BUILD "gettext"         "d20fcbb537e02dcf1383197ba05bd0734ef7bf5db06bdb241eb69b7d16b73192" "https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.xz"
BUILD "libffi"          "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056" "https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz"
#BUILD "zlib"
#BUILD "glib"
#BUILD "openjpeg"
BUILD "lcms"            "dc49b9c8e4d7cdff376040571a722902b682a795bf92985a85b48854c270772e" "https://downloads.sourceforge.net/project/lcms/lcms/2.11/lcms2-2.11.tar.gz"
BUILD "libtiff"         "6f3dbed9d2ecfed33c7192b5c01884078970657fa21b4ad28e3cdf3438eb2419" "https://download.osgeo.org/libtiff/tiff-4.1.0.zip"
BUILD "poppler"         "b4453804e9a5a519e6ceee0ac8f5efc229e3b0bf70419263c239124474d256c7" "https://poppler.freedesktop.org/poppler-0.88.0.tar.xz"

BUILD "fontconfig"      "506e61283878c1726550bc94f2af26168f1e9f2106eac77eaaf0b2cdfad66e4e" "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.92.tar.xz"
#BUILD "freetype"
#BUILD "glib"
#BUILD "libpng"
BUILD "pixman"          "6d200dec3740d9ec4ec8d1180e25779c00bc749f94278c8b9021f5534db223fc" "https://cairographics.org/releases/pixman-0.40.0.tar.gz"
#BUILD "zlib" 
BUILD "cairo"           "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331" "https://cairographics.org/releases/cairo-1.16.0.tar.xz"
#BUILD "freetype"
BUILD "gdk-pixbuf"      "1582595099537ca8ff3b99c6804350b4c058bb8ad67411bbaae024ee7cead4e6" "https://download.gnome.org/sources/gdk-pixbuf/2.40/gdk-pixbuf-2.40.0.tar.xz"
#BUILD "gio"
BUILD "libxml2"         "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f" "http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz"
BUILD "pango"           "d89fab5f26767261b493279b65cfb9eb0955cd44c07c5628d36094609fc51841" "https://download.gnome.org/sources/pango/1.46/pango-1.46.2.tar.xz"
BUILD "librsvg"         "6b708d6ba7eb165308625033622b6394af4250bf42ef399ef58fcb42e50d64ff" "https://github.com/GNOME/librsvg/archive/2.50.0.tar.gz"                                     "librsvg-2.50.0.tar.gz"

BUILD "libde265"        "eac6b56fcda95b0fe0123849c96c8759d832ec9baded2c9c0a5b5faeffb59005" "https://github.com/strukturag/libde265/releases/download/v1.0.7/libde265-1.0.7.tar.gz"
BUILD "libheif"         "5f65ca2bd2510eed4e13bdca123131c64067e9dd809213d7aef4dc5e37948bca" "https://github.com/strukturag/libheif/releases/download/v1.9.1/libheif-1.9.1.tar.gz"

BUILD "giflib"          "34a7377ba834397db019e8eb122e551a49c98f49df75ec3fcc92b9a794a4f6d1" "https://downloads.sourceforge.net/project/giflib/giflib-5.1.4.tar.gz"

BUILD "libvips"         "e089bb4f73e1dce866ae53e25604ea4f94535488a45bb4f633032e1d2f4e2dda" "https://github.com/libvips/libvips/releases/download/v8.10.1/vips-8.10.1.tar.gz"

####################################################################################################

cd "${BASE_DIR}/src"
make clean
make ${MAKE_JOBS}

cd "${BASE_DIR}/test"
make clean
make ${MAKE_JOBS}
