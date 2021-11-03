#!/bin/sh
WORKDIR=$(readlink -f $0 | sed 's/\(ibuki_m\)\(.*\)/\1/')
LIBDIR=${WORKDIR}/../swwmgzlib_m
DESTFILE=${WORKDIR}/../ibuki${1}_m.pk3
mkdir -p /tmp/tempwork
pushd /tmp/tempwork
cp -ar $LIBDIR/* .
cp -ar $WORKDIR/* .
7z a -tzip -mx=9 -x@tools/excl.lst -up0q0r2x2y2z1w2 $DESTFILE '*'
popd
rm -rf /tmp/tempwork
