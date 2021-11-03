#!/bin/sh
WORKDIR=$(readlink -f $0 | sed 's/\(ibuki_m\)\(.*\)/\1/')
pushd "$WORKDIR"
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=off -x@tools/excl.lst -up0q0r2x2y2z1w2 ../ibuki${1}_m.pk7 '../swwmgzlib_m/*' '*'
popd
