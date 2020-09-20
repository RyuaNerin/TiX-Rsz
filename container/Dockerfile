FROM buildpack-deps:buster

RUN \
  apt-get update && \
  apt-get install -y \
    g++-mingw-w64 \
    make \
    wine \
    mingw-w64-tools

ENTRYPOINT [ "/bin/bash", "/data/build/build.sh" ]

WORKDIR /data
