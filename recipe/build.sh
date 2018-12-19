#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

# This really mucks with the build.
rm -rf ${PREFIX}/lib/cmake/netCDF/*

# ls -1 /usr/lib/system/*
# ls -1 /Applications/Xcode-9.4.1.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/lib/system/*

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
