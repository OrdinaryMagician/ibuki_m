#!/bin/sh
WORKDIR=$(readlink -f $0 | sed 's/\(ibuki_m\)\(.*\)/\1/')
LIBDIR=${WORKDIR}/../swwmgzlib_m
DESTFILE=${WORKDIR}/../ibuki${1}_m.pk7
mkdir -p /tmp/tempwork
pushd /tmp/tempwork
cp -ar $LIBDIR/* .
cp -ar $WORKDIR/* .
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=off -x@tools/excl.lst -up0q0r2x2y2z1w2 $DESTFILE '*'
popd
rm -rf /tmp/tempwork
