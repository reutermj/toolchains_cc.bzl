#!/bin/bash
set -ex

ROOT_DIR=$(pwd)

sudo apk update
sudo apk add git coreutils diffutils make \
             gcc g++ bison flex texinfo \
             zlib-dev

# ===============================
# || Clone alpine package repo ||
# ===============================
APORTS=$ROOT_DIR/aports
git clone --depth 1 https://gitlab.alpinelinux.org/alpine/aports.git $APORTS

# =================================
# || Get GCC version from aports ||
# =================================
APORTS_BINUTILS_DIR=$APORTS/main/binutils
BINUTILS_VERSION=$(cat $APORTS_BINUTILS_DIR/APKBUILD | grep "pkgver=" | cut -d'=' -f2 | tr -d '[:space:]' | tr '.' '_')

# ==============================
# || Download GCC source code ||
# ==============================
BINUTILS_DIR=$ROOT_DIR/binutils
git clone --branch binutils-$BINUTILS_VERSION --depth 1 git://sourceware.org/git/binutils-gdb.git $BINUTILS_DIR

# ==================================================
# || Apply patches from aports to GCC source code ||
# ==================================================
cp -v $APORTS_BINUTILS_DIR/*.patch $BINUTILS_DIR

cd $BINUTILS_DIR
for patch in *.patch; do
    # git apply --check $patch
    git apply $patch || /bin/true
done

sed -i 's/stage1_ldflags=\"-static-libstdc++ -static-libgcc\"/\stage1_ldflags="-static\"/g' configure

mkdir build
cd build
../configure --prefix=/home/bazeler/binutils-out --disable-gdbserver --disable-gdb --disable-gprofng --disable-nls --disable-werror --disable-multilib --with-static-standard-libraries --disable-bootstrap
make -j $(nproc)
make install
