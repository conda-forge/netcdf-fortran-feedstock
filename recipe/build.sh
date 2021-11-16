#!/bin/bash

if [[ -n "$mpi" && "$mpi" != "nompi" ]]; then
  export PARALLEL="-DENABLE_PARALLEL4=ON -DENABLE_PARALLEL_TESTS=ON"
  export CC=mpicc
  export FC=mpif90
  export F77=mpif77
else
  export CC=$(basename ${CC})
  export FC=$(basename ${FC})
  export F77=$(basename ${F77})
  PARALLEL=""
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"
if [[ "$target_platform" == osx-* ]]; then
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
      ${PARALLEL} \
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

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  ctest -VV
fi
make install
