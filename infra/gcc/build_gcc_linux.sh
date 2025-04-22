#!/bin/bash
set -ex

ROOT_DIR=$(pwd)

sudo apk update
sudo apk add git coreutils diffutils make \
             gcc g++ bison flex texinfo gawk zip gmp-dev mpfr-dev mpc1-dev zlib-dev \
             linux-headers gmp-dev mpfr-dev mpc1-dev isl-dev zlib-dev libucontext-dev

# ===============================
# || Clone alpine package repo ||
# ===============================
APORTS=$ROOT_DIR/aports
git clone --depth 1 https://gitlab.alpinelinux.org/alpine/aports.git $APORTS

# =================================
# || Get GCC version from aports ||
# =================================
APORTS_GCC_DIR=$APORTS/main/gcc
GCC_VERSION=$(cat $APORTS_GCC_DIR/APKBUILD | grep "pkgver=" | cut -d'=' -f2 | tr -d '[:space:]')

# ==============================
# || Download GCC source code ||
# ==============================
GCC_DIR=$ROOT_DIR/gcc
git clone --depth 1 --branch releases/gcc-$GCC_VERSION git://gcc.gnu.org/git/gcc.git $GCC_DIR

# ==================================================
# || Apply patches from aports to GCC source code ||
# ==================================================
cp -v $APORTS_GCC_DIR/*.patch $GCC_DIR

cd $GCC_DIR
for patch in *.patch; do
    # git apply --check $patch
    git apply $patch || /bin/true
done

sed -i 's/stage1_ldflags=\"-static-libstdc++ -static-libgcc\"/\stage1_ldflags="-static\"/g' configure

mkdir build
cd build
../configure --prefix=/home/bazeler/gcc-out --enable-languages=c,c++ --disable-multilib --with-static-standard-libraries --disable-bootstrap
make -j $(nproc)
make install
