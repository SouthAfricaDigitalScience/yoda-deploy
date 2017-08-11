#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add gcc/${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-${GCC_VERSION}-mpi-1.8.8

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}

echo "All tests have passed, will now build into ${SOFT_DIR}"
make clean
PYTHON_VERSION=${PYTHON_VERSION:0:3} ./configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}

make install

echo "Creating the modules file directory ${HEP}"
mkdir -p ${HEP}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/YODA-deploy"

module add gcc/${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-${GCC_VERSION}-mpi-1.8.8

setenv YODA_VERSION       $VERSION
setenv YODA_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(YODA_DIR)/lib
prepend-path PATH                           $::env(YODA_DIR)/bin
setenv CPPFLAGS            "-I$::env(YODA_DIR)/include $CPPFLAGS"
setenv LDFLAGS           "-L$::env(YODA_DIR)/lib $LDFLAGS"
MODULE_FILE
) > ${HEP}/${NAME}/${VERSION}-gcc-${GCC_VERSION}
echo "checking module availability"
module avail ${NAME}
echo "Checking the module"
module add  ${NAME}/${VERSION}-gcc-${GCC_VERSION}
