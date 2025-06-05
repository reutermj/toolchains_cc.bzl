load("//impl:alpine.bzl", "extract_alpine")
load("//impl:ubuntu.bzl", "extract_ubuntu")

def _cxx_toolchain(rctx):
    """Implementation for the llvm_toolchain repository rule."""
    if rctx.attr.vendor == "default" or rctx.attr.vendor == "ubuntu":
        extract_ubuntu(rctx)
        target_triple = "x86_64-unknown-linux-gnu"
    elif rctx.attr.vendor == "alpine":
        extract_alpine(rctx)
        target_triple = "x86_64-alpine-linux-musl"
    else:
        fail("(toolchains_cc.bzl bug) Unknown vendor: %s" % rctx.attr.vendor)

    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/llvm-19.1.7-linux-x86_64.tar.xz",
    )

    if rctx.attr.cxx_std_lib == "default" or rctx.attr.cxx_std_lib == "libc++":
        cxx_std_lib = "libc++"
    elif rctx.attr.cxx_std_lib == "libstdc++":
        cxx_std_lib = "libstdc++"
    else:
        fail("(toolchains_cc.bzl bug) Unknown C++ standard library: %s" % rctx.attr.cxx_std_lib)

    rctx.template(
        "BUILD",
        rctx.attr._build_tpl,
        substitutions = {
            "%{toolchain_name}": rctx.original_name,
            "%{cxx_std_lib}": cxx_std_lib,
            "%{target_triple}": target_triple,
        },
    )

cxx_toolchain = repository_rule(
    implementation = _cxx_toolchain,
    attrs = {
        "vendor": attr.string(
            mandatory = False,
            doc = "The vendor of the target platform. Also determines the libc.",
            values = [
                "default",
                "ubuntu",
                "alpine",
            ],
            default = "default",
        ),
        "cxx_std_lib": attr.string(
            mandatory = False,
            doc = "The c++ standard library to use.",
            values = [
                "default",
                "libc++",
                "libstdc++",
            ],
            default = "default",
        ),
        "_build_tpl": attr.label(
            default = "//:BUILD.tpl",
        ),
    },
)
