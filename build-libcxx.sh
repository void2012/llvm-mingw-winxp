#!/bin/sh
#
# Copyright (c) 2018 Martin Storsjo
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# build command:
#./build-libcxx.sh --disable-shared --enable-static --enable-cfguard ./build/libcxx

set -e

BUILD_STATIC=ON
BUILD_SHARED=ON
CFGUARD_CFLAGS="-mguard=cf"

while [ $# -gt 0 ]; do
    if [ "$1" = "--disable-shared" ]; then
        BUILD_SHARED=OFF
    elif [ "$1" = "--enable-shared" ]; then
        BUILD_SHARED=ON
    elif [ "$1" = "--disable-static" ]; then
        BUILD_STATIC=OFF
    elif [ "$1" = "--enable-static" ]; then
        BUILD_STATIC=ON
    elif [ "$1" = "--enable-cfguard" ]; then
        CFGUARD_CFLAGS="-mguard=cf"
    elif [ "$1" = "--disable-cfguard" ]; then
        CFGUARD_CFLAGS=
    else
        PREFIX="$1"
    fi
    shift
done
if [ -z "$PREFIX" ]; then
    echo "$0 [--disable-shared] [--disable-static] [--enable-cfguard|--disable-cfguard] dest"
    exit 1
fi

mkdir -p "$PREFIX"
PREFIX="$(cd "$PREFIX" && pwd)"

export PATH="$PREFIX/bin:$PATH"

: ${ARCHS:=${TOOLCHAIN_ARCHS-i686 x86_64}}

if [ ! -d llvm-project/libunwind ] || [ -n "$SYNC" ]; then
    CHECKOUT_ONLY=1 ./build-llvm.sh
fi

cd llvm-project

cd runtimes

if command -v ninja >/dev/null; then
    CMAKE_GENERATOR="Ninja"
else
    : ${CORES:=$(nproc 2>/dev/null)}
    : ${CORES:=$(sysctl -n hw.ncpu 2>/dev/null)}
    : ${CORES:=4}

    case $(uname) in
    MINGW*)
        CMAKE_GENERATOR="MSYS Makefiles"
        ;;
    esac
fi

for arch in $ARCHS; do
    [ -z "$CLEAN" ] || rm -rf build-$arch
    mkdir -p build-$arch
    cd build-$arch
    [ -n "$NO_RECONF" ] || rm -rf CMake*
    cmake \
    ${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX/$arch-w64-mingw32" \
    -DCMAKE_TOOLCHAIN_FILE="C:/llvm-mingw/i686-llvm-mingw-toolchain.cmake" \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx" \
    -DLIBCXXABI_USE_LLVM_UNWINDER=FALSE \
    -DLIBCXX_ENABLE_FILESYSTEM=OFF \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXX_ENABLE_RTTI=OFF \
    -DLIBCXX_ENABLE_WIDE_CHARACTERS=ON\
    -DLIBCXX_HAS_PTHREAD_API=ON \
    -DLIBCXX_HAS_WIN32_THREAD_API=OFF \
    -DLIBCXX_USE_COMPILER_RT=OFF \
    -DLIBCXXABI_USE_COMPILER_RT=OFF \
    -DLIBCXXABI_HAS_PTHREAD_API=ON \
    -DLIBCXX_ENABLE_SHARED=$BUILD_SHARED \
    -DLIBCXX_ENABLE_STATIC=$BUILD_STATIC \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=TRUE \
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_LIBDIR_SUFFIX="" \
    -DLIBCXX_INCLUDE_TESTS=FALSE \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_INSTALL_MODULES_DIR="$PREFIX/share/libc++/v1" \
    -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=FALSE \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_LIBDIR_SUFFIX="" \
    -DCMAKE_C_FLAGS_INIT="$CFGUARD_CFLAGS" \
    -DCMAKE_CXX_FLAGS_INIT="$CFGUARD_CFLAGS -D_LIBCPP_VERBOSE_ABORT="(decltype(::std::__use(__VA_ARGS__))(), __builtin_abort())"" \
        ..

    cmake --build . ${CORES:+-j${CORES}}
    cmake --install .
    cd ..
done
