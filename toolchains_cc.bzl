load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")

def _cxx_toolchain(rctx):
    """Implementation for the llvm_toolchain repository rule."""
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/llvm-19.1.7-linux-x86_64.tar.xz",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libc6_2.41-6ubuntu1_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libc6-dev_2.41-6ubuntu1_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libgcc-15-dev_15-20250404-0ubuntu1_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libstdc++-15-dev_15-20250404-0ubuntu1_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/libgcc-s1_15-20250404-0ubuntu1_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/linux-headers-6.14.0-15-generic_6.14.0-15.15_amd64.tar.xz",
        output = "sysroot",
    )
    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/linux-libc-dev_6.14.0-15.15_amd64.tar.xz",
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
