
set "LDFLAGS=%LDFLAGS% -L%PREFIX%\lib -Wl,-rpath,%PREFIX%\lib -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf"
set "CFLAGS=%CFLAGS% -fPIC -I%PREFIX%\include"


:: This really mucks with the build.
:: The cmake build in this repo appears to use the information from the
:: cmake build of libnetcdf. This causes incorrect linkages, missing libraries
:: and general chaos in the builds here. An attempt at patching upstream was
:: made, but getting that working fully and robustly appears difficult. This
:: should just work all the time.
rmdir "%PREFIX%\lib\cmake\netCDF\*" /s /q

:: Build static.
mkdir build_static
cd build_static
cmake -D CMAKE_INSTALL_PREFIX=%PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR:PATH=%PREFIX%\lib ^
      -D BUILD_SHARED_LIBS=OFF ^
      %PARALLEL% ^
      %SRC_DIR%

make
make install
make clean
cd ..

:: Build shared.
mkdir build_shared && cd build_shared
cmake -D CMAKE_INSTALL_PREFIX=%PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR:PATH=%PREFIX%\lib ^
      -D BUILD_SHARED_LIBS=ON ^
      %SRC_DIR%

make
ctest
make install
