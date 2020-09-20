#!/bin/bash

on_err() {
    ERROR_CODE=$?
    echo "error ${ERROR_CODE}"
    echo "the command executing at the time of the error was"
    echo "${BASH_COMMAND}"
    echo "on line ${BASH_LINENO[0]}"
    exit ${ERROR_CODE}
}
trap on_err ERR

ln -sf /data/build-win64-mxe/build/mxe /data/mxe

export PKG_CONFIG_LIBDIR=/data/mxe/usr/x86_64-w64-mingw32.static.win32.web/lib/pkgconfig

cd /data/src
make

cd /data/test
make
make test
