#!/bin/bash

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g $CFLAGS"
export CXXFLAGS="-g $CXXFLAGS"
# pari sends LDFLAGS to LD if set, but LDFLAGS are meant for the compiler to pass to linker.
unset LD

if [ "$(uname)" == "Linux" ]
then
   export LDFLAGS="$LDFLAGS -Wl,-rpath-link,${PREFIX}/lib"
fi

unset GP_INSTALL_PREFIX # we do not want this to be set by the user

# In addition, a lot of variables used (internally) by PARI might un-
# intentionally get their values from the "global" environment, so it's
# safer to clear them here (not further messing up PARI's scripts):
unset static tune timing_fun error
unset enable_tls
unset with_fltk with_qt
unset with_ncurses_lib
unset with_readline_include with_readline_lib without_readline
unset with_gmp_include with_gmp_lib without_gmp
unset dfltbindir dfltdatadir dfltemacsdir dfltincludedir
unset dfltlibdir dfltmandir dfltsysdatadir dfltobjdir


LINK=http://pari.math.u-bordeaux.fr/pub/pari/packages


curl -L -O $LINK/seadata-small.tgz
sha256=`openssl dgst -sha256 seadata-small.tgz`
expected_sha256="SHA256(seadata-small.tgz)= bf5be913472b268df7f1242f94c68113fcacceb30c280507447ff2be62760a8f"
if [ "$sha256" != "$expected_sha256" ]
then
    echo "seadata-small.tgz checksum failure"
    exit 1;
fi
tar -xvf seadata-small.tgz


curl -L -O $LINK/galdata.tgz
sha256=`openssl dgst -sha256 galdata.tgz`
expected_sha256="SHA256(galdata.tgz)= b7c1650099b24a20bdade47a85a928351c586287f0d4c73933313873e63290dd"
if [ "$sha256" != "$expected_sha256" ]
then
    echo "galdata.tgz checksum failure"
    exit 1;
fi
tar -xvf galdata.tgz

mkdir -p "$PREFIX"/share/pari
cp -R data/* "$PREFIX"/share/pari/

chmod +x Configure
./Configure --prefix="$PREFIX" \
        --with-readline="$PREFIX" \
        --with-gmp="$PREFIX" \
        --with-runtime-perl="$PREFIX/bin/perl" \
        --kernel=gmp \
        --graphic=none

make gp

if [ "$(uname)" == "Linux" ]
then
    make test-all;
fi

make install install-lib-sta
cp "src/language/anal.h" "$PREFIX/include/pari/anal.h"
