#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"
if [[ $(uname) == Darwin ]] && [[ "${CC}" != "clang" ]]; then
  export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
fi

# This really mucks with the build.
# The cmake build in this repo appears to use the information from the
# cmake build of libnetcdf. This causes incorrect linkages, missing libraries
# and general chaos in the builds here. An attempt at patching upstream was
# made, but getting that working fully and robustly appears difficult. This
# should just work all the time.
rm -rf ${PREFIX}/lib/cmake/netCDF/*

# Build static.
mkdir build_static && cd build_static
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D BUILD_SHARED_LIBS=OFF \
      $SRC_DIR

make
# ctest  # Run only for the shared lib build to save time.
make install

make clean
cd ..

# Build shared.
mkdir build_shared && cd build_shared
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D BUILD_SHARED_LIBS=ON \
      $SRC_DIR

make
ctest
make install

# We can remove this when we start using the new conda-build.
find $PREFIX -name '*.la' -delete
