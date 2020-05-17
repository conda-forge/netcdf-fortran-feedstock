set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"
set "MINGWBIN=%LIBRARY_PREFIX%/mingw-w64/bin"

:: These flags cause errors during CMake; disable for now?
set "LDFLAGS=-L%LIBRARY_PREFIX%/lib -Wl,-rpath,%LIBRARY_PREFIX%/lib"
::            Left out: -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf
set "CFLAGS=-fPIC -I%LIBRARY_PREFIX%/include"
:: PENDING -> PARALLEL MPI STUFF
set PARALLEL=""

:: This really mucks with the build.
:: The cmake build in this repo appears to use the information from the
:: cmake build of libnetcdf. This causes incorrect linkages, missing libraries
:: and general chaos in the builds here. An attempt at patching upstream was
:: made, but getting that working fully and robustly appears difficult. This
:: should just work all the time.
rmdir "%LIBRARY_LIB%\cmake\netCDF" /s /q

:: Build static.
rmdir build_static /s /q
mkdir build_static
cd build_static
cmake -G "MinGW Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR:PATH=%LIBRARY_PREFIX%/lib ^
      -D BUILD_SHARED_LIBS=OFF ^
      -D CMAKE_C_COMPILER:PATH=%MINGWBIN%/gcc.exe ^
      -D CMAKE_Fortran_COMPILER:PATH=%MINGWBIN%/gfortran.exe ^
      %PARALLEL% ^
      %SRC_DIR%
if errorlevel 1 exit 1

mingw32-make
if errorlevel 1 exit 1
:: ctest
:: if errorlevel 1 exit 1
mingw32-make install
if errorlevel 1 exit 1


mingw32-make clean
cd ..

:: Build shared.
rmdir build_shared /s /q
mkdir build_shared
cd build_shared
cmake -G "MinGW Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR:PATH=%LIBRARY_PREFIX%/lib ^
      -D BUILD_SHARED_LIBS=ON ^
      -D CMAKE_C_COMPILER=%MINGWBIN%/gcc.exe ^
      -D CMAKE_Fortran_COMPILER=%MINGWBIN%/gfortran.exe ^
      %SRC_DIR%
if errorlevel 1 exit 1

mingw32-make
if errorlevel 1 exit 1
ctest
if errorlevel 1 exit 1
mingw32-make install
if errorlevel 1 exit 1

cd %cwd%