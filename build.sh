#!/bin/bash
set -e

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

echo "Removing previous result if present"
test -f result.tgz && rm result.tgz

echo "Building docker container with toolchain and requirements"
docker build -t mijia-720p-hack ${SCRIPTPATH} $@

echo "Building mijia-720p-hack"
docker run -i                  \
    -v "${SCRIPTPATH}:/result" \
    --detach=false             \
    --tty=true                 \
    --rm                       \
    --dns "8.8.8.8"            \
mijia-720p-hack /bin/bash -c 'make && make install && tar czf /result/image.tgz /build/sdcard'
