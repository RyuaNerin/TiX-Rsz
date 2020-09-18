FROM buildpack-deps:buster

RUN \
  apt-get update && \
  apt-get install -y \
    g++-mingw-w64 \
    wine

ENTRYPOINT [ "/bin/make" ]

WORKDIR /data/src
