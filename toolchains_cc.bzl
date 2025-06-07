load("//impl:alpine.bzl", "extract_alpine")
load("//impl:ubuntu.bzl", "extract_ubuntu")

def _lazy_download_bins(rctx):
    if rctx.attr.vendor == "default" or rctx.attr.vendor == "ubuntu":
        extract_ubuntu(rctx)
    elif rctx.attr.vendor == "alpine":
        extract_alpine(rctx)
    else:
        fail("(toolchains_cc.bzl bug) Unknown vendor: %s" % rctx.attr.vendor)

    rctx.download_and_extract(
        url = "https://github.com/reutermj/toolchains_cc.bzl/releases/download/binaries/llvm-19.1.7-linux-x86_64.tar.xz",
    )

    rctx.template(
        "BUILD",
        rctx.attr._build_tpl,
    )

def _cxx_toolchain(rctx):
    """Implementation for the llvm_toolchain repository rule."""
    if rctx.attr.vendor == "default" or rctx.attr.vendor == "ubuntu":
        target_triple = "x86_64-unknown-linux-gnu"
        vendor = "ubuntu"
    elif rctx.attr.vendor == "alpine":
        target_triple = "x86_64-alpine-linux-musl"
        vendor = "alpine"
    else:
        fail("(toolchains_cc.bzl bug) Unknown vendor: %s" % rctx.attr.vendor)

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
            "%{bins_repo_name}": rctx.name + "_bins",
            "%{vendor}": vendor,
        },
    )

lazy_download_bins = repository_rule(
    implementation = _lazy_download_bins,
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
            default = "@toolchains_cc.bzl//:bins.BUILD.tpl",
        ),
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
            default = "@toolchains_cc.bzl//:toolchain.BUILD.tpl",
        ),
    },
)

def _cxx_toolchains(module_ctx):
    for mod in module_ctx.modules:
        for declared_toolchain in mod.tags.declare:
            # more context: https://github.com/reutermj/toolchains_cc.bzl/issues/1
            cxx_toolchain(
                name = declared_toolchain.name,
                vendor = declared_toolchain.vendor,
                cxx_std_lib = declared_toolchain.cxx_std_lib,
            )
            lazy_download_bins(
                name = declared_toolchain.name + "_bins",
                vendor = declared_toolchain.vendor,
                cxx_std_lib = declared_toolchain.cxx_std_lib,
            )

cxx_toolchains = module_extension(
    implementation = _cxx_toolchains,
    tag_classes = {
        "declare": tag_class(
            attrs = {
                "name": attr.string(
                    mandatory = True,
                    doc = "The name of the toolchain, used for registration.",
                ),
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
            },
        ),
    },
)
