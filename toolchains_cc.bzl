load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")

def _cxx_toolchain(rctx):
    """Implementation for the llvm_toolchain repository rule."""
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/llvm-19.1.7-linux-x86_64.tar.xz",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libc6_2.35-0ubuntu3.10_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libc6-dev_2.35-0ubuntu3.10_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libgcc-12-dev_12.3.0-1ubuntu1.22.04_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libgcc-s1_12.3.0-1ubuntu1.22.04_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libstdc++-12-dev_12.3.0-1ubuntu1.22.04_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/linux-headers-5.15.0-140-generic_5.15.0-140.150_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/linux-libc-dev_5.15.0-140.150_amd64.tar.xz",
        output = "sysroot",
    )
    # Create a BUILD file to make this a valid Bazel package
    rctx.template(
        "BUILD",
        rctx.attr._build_tpl,
        substitutions = {
            "%{toolchain_name}": rctx.original_name,
        }
    )
    

cxx_toolchain = repository_rule(
    implementation = _cxx_toolchain,
    attrs = {
        "_build_tpl": attr.label(
            default = "//:BUILD.tpl",
        ),
    },
)
