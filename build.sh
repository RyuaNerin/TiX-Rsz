#!/bin/sh

if ! [ -x "$(command -v docker)" ]; then
    echo "Please install docker"
    exit 1
fi

# Build libvips web x86_64 static
git clone -b 'v8.10.1' --single-branch https://github.com/libvips/build-win64-mxe
( \
    cd build-win64-mxe; \
    for i in ../patches/*.patch; do patch -l -p1 < "$i"; done; \
    ./build.sh web x86_64 static \
)
unzip build-win64-mxe/build/*.zip -d . || exit 1

mv "$(find `pwd` -maxdepth 1 -type d -iname 'vips-dev-*')" vips-dev

exit 1

##################################################
docker pull buildpack-deps:buster

docker build -t tixrsz-build container

docker run --rm -t \
    -u $(id -u):$(id -g) \
    -v $PWD:/data \
    tixrsz-build
