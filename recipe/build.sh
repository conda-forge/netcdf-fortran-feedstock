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

# For cross compiling with openmpi
export OPAL_PREFIX=$PREFIX

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

# Build shared.
mkdir build_shared && cd build_shared
cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D BUILD_SHARED_LIBS=ON \
      $SRC_DIR

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest -VV
fi
make install

sed -i.bu "s:${BUILD_PREFIX}:${PREFIX}:g" ${PREFIX}/bin/nf-config && rm ${PREFIX}/bin/nf-config
