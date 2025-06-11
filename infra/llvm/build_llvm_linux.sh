#!/bin/bash
set -ex

ROOT_DIR=$(pwd)

# not super sure if all of these are necessary
sudo apk update
sudo apk add git coreutils diffutils sudo \
             musl-dev \
             gcc g++ binutils-dev \
             make cmake samurai \
             python3 py3-setuptools \
             libffi-dev openssl-dev \
             ncurses-dev libedit-dev libxml2-dev zlib-dev zlib-static

# For whatever reason, alpine's ninja package wasnt adding ninja to the PATH
if ! command -v ninja &> /dev/null; then
    export PATH="/usr/lib/ninja-build/bin:${PATH}"
fi
if ! command -v ninja &> /dev/null; then
    exit 0
fi


# ===============================
# || Clone alpine package repo ||
# ===============================
APORTS=$ROOT_DIR/aports
git clone --depth 1 https://gitlab.alpinelinux.org/alpine/aports.git $APORTS

# ==================================
# || Get LLVM version from aports ||
# ==================================
LLVM_DIRS=$(find $APORTS/main -maxdepth 1 -type d -name 'llvm[0-9]*')
LATEST_LLVM_MAJOR_VERSION=0
for DIR in $LLVM_DIRS; do
    VERSION=$(basename $DIR | grep -o '[0-9]\+')
    if (( VERSION > LATEST_LLVM_MAJOR_VERSION )); then
        LATEST_LLVM_MAJOR_VERSION=$VERSION
    fi
done

APORTS_LLVM_DIR=$APORTS/main/llvm$LATEST_LLVM_MAJOR_VERSION
APORTS_CLANG_DIR=$APORTS/main/clang$LATEST_LLVM_MAJOR_VERSION
LLVM_VERSION=$(cat $APORTS_LLVM_DIR/APKBUILD | grep "pkgver=" | cut -d'=' -f2 | tr -d '[:space:]')

# ===============================
# || Download LLVM source code ||
# ===============================
LLVM_PROJECT=$ROOT_DIR/llvm-project
mkdir $LLVM_PROJECT
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-project-${LLVM_VERSION}.src.tar.xz
# --strip-components=1: the llvm tarball contains a top-level directory named llvm-project-<version>.src
#                       we want to extract the contents of it directly into the llvm-project directory.
tar --strip-components=1 -xvf llvm-project-${LLVM_VERSION}.src.tar.xz -C $LLVM_PROJECT

# to git apply patches, it needs to be a git repo
# it takes way longer to git clone llvm than to download the tarball
git config --global user.email "nobody@example.com"
git config --global user.name "nobody"
cd $LLVM_PROJECT
git init
git add .
git commit -m "Dummy commit to apply patches"

# ===================================================
# || Apply patches from aports to LLVM source code ||
# ===================================================
cp -v $APORTS_LLVM_DIR/*.patch $LLVM_PROJECT
cp -v $APORTS_CLANG_DIR/*.patch $LLVM_PROJECT/clang

for patch in *.patch; do
    git apply --check $patch
    git apply $patch
done

pushd $LLVM_PROJECT/clang
for patch in *.patch; do
    git apply --check $patch
    git apply $patch
done
popd

# I was getting some weird error with gcc that I didnt write down
# Might also not be necessary anymore. Havent retested gcc.
CC=clang
CXX=clang++

# Tell the compiler to link statically
CMAKE_C_FLAGS="-static"
CMAKE_CXX_FLAGS="-static"

# these warnings make the build output difficult to read when debugging the build
# Im not a clang developer so I dont care about these warnings
CMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS -Wno-attributes -Wno-dangling-reference -Wno-alloc-size-larger-than -Wno-implicit-fallthrough -Wno-array-bounds"

# building libclang.so with -static fails on some relocation error
# I dont care about libclang.so, so Im fine with disabling it
# this flag very indirectly disables building libclang.so
# https://github.com/llvm/llvm-project/blob/main/clang/tools/libclang/CMakeLists.txt#L109-L115
LLVM_ENABLE_PIC="OFF"
# These two dont seem necessary but adding just in case
LIBCLANG_BUILD_STATIC="ON"
BUILD_SHARED_LIBS="OFF"

# Im getting this error when trying to link stuff with lld
# ld.lld: error: <sysroot>/usr/lib/libc.a(memchr.lo):(.debug_info) is compressed with ELFCOMPRESS_ZLIB, 
# but lld is not built with zlib support
# ON is more of a suggestion. FORCE_ON is will error the build if it doesnt find zlib
LLVM_ENABLE_ZLIB="FORCE_ON"
LLVM_ENABLE_ZSTD="FORCE_ON"

# We want to link zlib statically
# also this mysteriously solved an error when configuring zlib in the cmake
# no idea...
ZLIB_USE_STATIC_LIBS="ON"

cmake -G Ninja -S llvm -B build \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_C_FLAGS="$CMAKE_C_FLAGS" \
      -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
      -DLLVM_ENABLE_PIC="$LLVM_ENABLE_PIC" \
      -DLIBCLANG_BUILD_STATIC="$LIBCLANG_BUILD_STATIC" \
      -DBUILD_SHARED_LIBS="$BUILD_SHARED_LIBS" \
      -DLLVM_ENABLE_ZLIB="$LLVM_ENABLE_ZLIB" \
      -DZLIB_USE_STATIC_LIBS="$ZLIB_USE_STATIC_LIBS" \
      -DCMAKE_BUILD_TYPE=Release

ninja -C build || /bin/true
