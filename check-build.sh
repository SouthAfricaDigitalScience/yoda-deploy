#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-${GCC_VERSION}-mpi-1.8.8
cd ${WORKSPACE}/${NAME}-${VERSION}
make check

echo $?

make install

mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."

module add gcc/${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-${GCC_VERSION}-mpi-1.8.8


setenv       YODA_VERSION       $VERSION
setenv       YODA_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(YODA_DIR)/lib
prepend-path PATH                           $::env(YODA_DIR)/bin
setenv CPPFLAGS            "-I$::env(YODA_DIR)/include $CPPFLAGS"
setenv LDFLAGS           "-L$::env(YODA_DIR)/lib $LDFLAGS"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -vp ${HEP}/${NAME}
cp -v modules/$VERSION ${HEP}/${NAME}

echo "checking module availability"
module avail ${NAME}
echo "Checking the module"
module add  ${NAME}/${VERSION}-gcc-${GCC_VERSION}
