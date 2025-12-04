set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"

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
cmake -LAH -G "Ninja" ^
      %CMAKE_ARGS% ^
      -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D BUILD_SHARED_LIBS=ON ^
      -D CMAKE_GNUtoMS:BOOL=ON ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D BUILD_V2:BOOL=OFF ^
      %PARALLEL% ^
      %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config %BUILD_TYPE% --target install
if errorlevel 1 exit 1
# Skipping ftst_vars for now, which may be failing due to:
# https://github.com/Unidata/netcdf-c/issues/2815
ctest -VV -E "ftst_vars"
if errorlevel 1 exit 1

cd %cwd%
