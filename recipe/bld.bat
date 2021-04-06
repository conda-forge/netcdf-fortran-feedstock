mkdir %SRC_DIR%\build
cd %SRC_DIR%\build

set BUILD_TYPE=Release
:: set BUILD_TYPE=RelWithDebInfo
:: set BUILD_TYPE=Debug

rem manually specify hdf5 paths to work-around https://github.com/Unidata/netcdf-c/issues/1444
cmake -LAH -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D BUILD_SHARED_LIBS=OFF ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      %SRC_DIR%
if errorlevel 1 exit \b 1

cmake --build . --config %BUILD_TYPE% --target install
if errorlevel 1 exit \b 1

rem :: We need to add some entries to PATH before running the tests
rem set ORIG_PATH=%PATH%
rem set PATH=%CD%\liblib\%BUILD_TYPE%;%CD%\liblib;%PREFIX%\Library\bin;%PATH%

rem :: 6 or 7 tests fail due to minor floating point / format string differences in the VS2008 build
rem goto end_tests
rem if "%vc%" == "9" goto vc9_tests
rem ctest -VV
rem if errorlevel 1 exit \b 1
rem goto end_tests
rem :vc9_tests
rem ctest -VV
rem :end_tests
