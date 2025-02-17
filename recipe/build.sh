#!/usr/bin/env bash
set -e

# LIBRARY_PREFIX will only be available on Windows
if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

if [[ "${target_platform}" == win-* ]]; then
  EXTRA_FLAGS="--enable-msvc --with-coinutils-lib=${LIBRARY_PREFIX}/lib/libCoinUtils.lib --with-coinutils-incdir=\${LIBRARY_PREFIX_COIN}"
  BLAS_LIB="${LIBRARY_PREFIX}/lib/cblas.lib"
  LAPACK_LIB="${LIBRARY_PREFIX}/lib/lapack.lib"
else
  # Get an updated config.sub and config.guess (for mac arm and lnx aarch64)
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./Osi 
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
  BLAS_LIB="-L${PREFIX}/lib -lblas"
  LAPACK_LIB="-L${PREFIX}/lib -llapack"
fi

./configure \
  --prefix="${USE_PREFIX}" \
  --exec-prefix="${USE_PREFIX}" \
  --with-blas-lib="${BLAS_LIB}" \
  --with-lapack-lib="${LAPACK_LIB}" \
  ${EXTRA_FLAGS} || cat Osi/config.log

make -j "${CPU_COUNT}"

# Tests are broken without Data folder: https://github.com/coin-or/Osi/issues/184
#if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
#  make test
#fi

make install
