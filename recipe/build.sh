#!/bin/bash

# See http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg11939.html
if [ "$(uname)" == "Darwin" ]; then
    export DYLD_LIBRARY_PATH=${PREFIX}/lib
fi

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CFLAGS="-fPIC $CFLAGS"

./configure --prefix=$PREFIX

make
make check
make install
