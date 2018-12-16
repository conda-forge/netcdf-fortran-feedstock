#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

if [[ `uname` == "Linux" ]] && [[ "$CC" != "gcc" ]]; then
    export CMAKE_PLATFORM_FLAGS="-DCMAKE_TOOLCHAIN_FILE=\"${RECIPE_DIR}/cross-linux.cmake\""
elif [[ `uname` == "Darwin" ]] && [[ "$CC" != "clang" ]]; then
    echo "here"
    export CMAKE_PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=\"${CONDA_BUILD_SYSROOT}\""
fi

# for debugging
echo "CMAKE_PLATFORM_FLAGS: ${CMAKE_PLATFORM_FLAGS}"

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
mkdir build_shared && cd build_shared
# Build shared.
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D BUILD_SHARED_LIBS=ON \
      $SRC_DIR

make
ctest
make install

# We can remove this when we start using the new conda-build.
find $PREFIX -name '*.la' -delete
