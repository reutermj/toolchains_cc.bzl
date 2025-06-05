visibility(["//..."])

def _extract_glibc(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc6_2.35-0ubuntu3.10_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc6-dev_2.35-0ubuntu3.10_amd64.tar.xz",
        output = "sysroot",
    )

def _extract_libgcc(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libgcc-12-dev_12.3.0-1ubuntu1.22.04_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libgcc-s1_12.3.0-1ubuntu1.22.04_amd64.tar.xz",
        output = "sysroot",
    )

def _extract_libstdcxx(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libstdc++-12-dev_12.3.0-1ubuntu1.22.04_amd64.tar.xz",
        output = "sysroot",
    )

def _extract_libcxx(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++-15-dev_15.0.7-0ubuntu0.22.04.3_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++1-15_15.0.7-0ubuntu0.22.04.3_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++abi-15-dev_15.0.7-0ubuntu0.22.04.3_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libc++abi1-15_15.0.7-0ubuntu0.22.04.3_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libunwind-15_15.0.7-0ubuntu0.22.04.3_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/libunwind-15-dev_15.0.7-0ubuntu0.22.04.3_amd64.tar.xz",
        output = "sysroot",
    )

def _extract_linux_sdk(rctx):
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/linux-headers-5.15.0-140-generic_5.15.0-140.150_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/linux-libc-dev_5.15.0-140.150_amd64.tar.xz",
        output = "sysroot",
    )

def extract_ubuntu(rctx):
    _extract_glibc(rctx)
    _extract_libgcc(rctx)
    _extract_linux_sdk(rctx)

    if rctx.attr.cxx_std_lib == "default" or rctx.attr.cxx_std_lib == "libc++":
        _extract_libcxx(rctx)
    elif rctx.attr.cxx_std_lib == "libstdc++":
        _extract_libstdcxx(rctx)
    else:
        fail("(toolchains_cc.bzl bug) Unknown C++ standard library: %s" % rctx.attr.cxx_std_lib)
