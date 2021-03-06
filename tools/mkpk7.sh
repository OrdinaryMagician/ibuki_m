#!/bin/sh
WORKDIR=$(dirname $(dirname $(readlink -f ${0}))) # this is ugly as all fuck but it works™
LIBDIR=${WORKDIR}/../swwmgzlib_m
MODNAME=$(basename $WORKDIR | sed 's/_m$//')
if [ ! -d $LIBDIR ]; then
  echo "Demolitionist Common Library not found, cannot proceed."
  exit 1
fi
DESTFILE=${WORKDIR}/../${MODNAME}${1}_m.pk7
TEMPDIR=$(mktemp -d)
pushd ${TEMPDIR}
cp -ar ${LIBDIR}/* .
cp -ar ${WORKDIR}/* .
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=off -x@tools/excl.lst -up0q0r2x2y2z1w2 ${DESTFILE} '*'
popd
rm -rf ${TEMPDIR}
