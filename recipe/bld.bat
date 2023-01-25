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

set BUILD_TYPE=Release
:: set BUILD_TYPE=RelWithDebInfo
:: set BUILD_TYPE=Debug

:: Build shared.
rmdir build_shared /s /q
mkdir build_shared
cd build_shared
cmake -LAH -G "MinGW Makefiles" ^
      %CMAKE_ARGS% ^
      -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D BUILD_SHARED_LIBS=ON ^
      -D CMAKE_C_COMPILER:PATH=%MINGWBIN%/gcc.exe ^
      -D CMAKE_Fortran_COMPILER:PATH=%MINGWBIN%/gfortran.exe ^
      -D CMAKE_GNUtoMS:BOOL=ON ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D BUILD_V2:BOOL=OFF ^
      %PARALLEL% ^
      %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config %BUILD_TYPE% --target install
if errorlevel 1 exit 1
ctest
if errorlevel 1 exit 1

cd %cwd%
