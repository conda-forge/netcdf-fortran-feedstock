#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

# This really mucks with the build.
rm -rf ${PREFIX}/lib/cmake/netCDF/*

# And a total hack - the anaconda compiler build looks for stuff that
# is supposed to be in CONDA_BUILD_SYSROOT in /usr/lib
if [[ `uname` == "Darwin" ]] && [[ "${CC}" != "clang" ]]; then
    # export LDFLAGS="$LDFLAGS --sysroot=${CONDA_BUILD_SYSROOT}"
    # export CFLAGS="$CFLAGS --sysroot=${CONDA_BUILD_SYSROOT}"
    # export FFLAGS="$FFLAGS --sysroot=${CONDA_BUILD_SYSROOT}"

    # mkdir -p /usr/lib/system
    # for lb in `ls ${CONDA_BUILD_SYSROOT}/usr/lib/system/*.dylib`; do
    #     if [ ! -f /usr/lib/system/`basename $lb` ]; then
    #         sudo ln -s $lb /usr/lib/system/`basename $lb`
    #     fi
    # done
fi

# Build static.
mkdir build_static && cd build_static
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -DBUILD_SHARED_LIBS=OFF \
      $SRC_DIR

make
# ctest  # Run only for the shared lib build to save time.
make install

make clean

cd ..
mkdir build_shared && cd build_shared
# Build shared.
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -DBUILD_SHARED_LIBS=ON \
      $SRC_DIR

make
ctest
make install

# We can remove this when we start using the new conda-build.
find $PREFIX -name '*.la' -delete
