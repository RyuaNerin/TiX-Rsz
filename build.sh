#!/bin/sh

if ! [ -x "$(command -v docker)" ]; then
    echo "Please install docker"
    exit 1
fi

on_err() {
    ERROR_CODE=$?
    echo "error ${ERROR_CODE}"
    echo "the command executing at the time of the error was"
    echo "${BASH_COMMAND}"
    echo "on line ${BASH_LINENO[0]}"
    exit ${ERROR_CODE}
}
trap on_err ERR

# Build libvips web x86_64 static + imagemagick
if ! [ -d "vips-dev" ]; then
    if ! [ -d "build-win64-mxe" ]; then
        git clone -b 'v8.10.1' --single-branch https://github.com/libvips/build-win64-mxe
    fi
    
    for i in ./patches-mxe/*.patch; do
        cp -f "$i" "build-win64-mxe/build/patches/"
    done;

    ( \
        cd build-win64-mxe; \
        for i in ../patches/*.patch; do \
            echo "PATCH : $i"; \
            patch -l -p1 --forward < "$i" || true; \
            echo; \
        done; \
        ./build.sh web x86_64 static \
    )

    cp build-win64-mxe/build/*.zip .

    find "${PWD}/vips-dev/lib/" -type f -exec \
            sed -i 's/\/data\/mxe\//\/data\/build\-win64\-mxe\/build\/mxe\//g' {} +
    
fi

##################################################
docker pull buildpack-deps:buster

docker build -t tixrsz-build container

docker run --rm -t \
    -u $(id -u):$(id -g) \
    -v $PWD:/data \
    tixrsz-build
