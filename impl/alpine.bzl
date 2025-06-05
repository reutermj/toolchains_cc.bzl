visibility(["//..."])

def _extract_musl(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/musl-1.2.5-r10.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/musl-dev-1.2.5-r10.tar.xz",
        output = "sysroot",
    )

def _extract_libgcc(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libgcc-14.2.0-r6.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/gcc-14.2.0-r6.tar.xz",
        output = "sysroot",
    )

def _extract_libstdcxx(rctx):
    # TODO broken currently. unable to find iostream. the alpine package puts it in a directory that clang does not search.
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libstdc++-14.2.0-r6.tar.xz",
        output = "sysroot",
    )

def _extract_linux_sdk(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/linux-headers-6.14.2-r0.tar.xz",
        output = "sysroot",
    )

def _extract_libcxx(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++-20.1.6-r0.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++-dev-20.1.6-r0.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++-static-20.1.6-r0.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/llvm-libunwind-20.1.6-r0.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/llvm-libunwind-dev-20.1.6-r0.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/llvm-libunwind-static-20.1.6-r0.tar.xz",
        output = "sysroot",
    )

def extract_alpine(rctx):
    _extract_musl(rctx)
    _extract_libgcc(rctx)
    _extract_linux_sdk(rctx)

    if rctx.attr.cxx_std_lib == "default" or rctx.attr.cxx_std_lib == "libc++":
        _extract_libcxx(rctx)
    elif rctx.attr.cxx_std_lib == "libstdc++":
        _extract_libstdcxx(rctx)
    else:
        fail("(toolchains_cc.bzl bug) Unknown C++ standard library: %s" % rctx.attr.cxx_std_lib)
