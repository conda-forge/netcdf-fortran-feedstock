set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"
set "MINGWBIN=%LIBRARY_PREFIX%/mingw-w64/bin"

set "LDFLAGS=-L%LIBRARY_PREFIX%/lib -Wl,-rpath,%LIBRARY_PREFIX%/lib "
:: -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf"
set "CFLAGS=-fPIC -I%LIBRARY_PREFIX%/include"

:: PENDING -> PARALLEL MPI STUFF
set PARALLEL=""
bash -lc "mkdir -p /tmp"
bash -lc "./configure --prefix=$(cygpath -u $LIBRARY_PREFIX)"

if errorlevel 1 exit 1

make
if errorlevel 1 exit 1
:: ctest
:: if errorlevel 1 exit 1
make install
if errorlevel 1 exit 1