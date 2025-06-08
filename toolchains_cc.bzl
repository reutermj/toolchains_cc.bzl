load("//impl:alpine.bzl", "extract_alpine")
load("//impl:ubuntu.bzl", "extract_ubuntu")

def _lazy_download_bins_impl(rctx):
    """Lazily downloads only the toolchain binaries for the configured platform."""
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

def _eager_declare_toolchain_impl(rctx):
    """Eagerly declare the toolchain(...) to determine which registered toolchain is valid for the current platform."""
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

def _detect_host_platform_impl(rctx):
    result = rctx.execute(["ldd", "--version"])

    ldd_output = result.stdout.lower()
    if ldd_output.find("glibc") != -1:
        # target_libc = "glibc"
        target_libc = "ubuntu"

        # This assumes that the output of ldd for glibc based systems is formatted like:
        # ldd (<distro> GLIBC <distro libc version>) <libc version>
        libc_version = ldd_output.splitlines()[0].split(" ")[-1].strip()
    elif ldd_output.find("musl") != -1:
        # target_libc = "musl"
        target_libc = "alpine"

        # musl libc (<arch>)
        # Version <libc version>
        libc_version = ldd_output.splitlines()[1].split(" ")[-1].strip()
    else:
        fail("(toolchains_cc.bzl bug) Unknown libc: %s" % ldd_output)

    rctx.file("BUILD")
    rctx.file(
        "platform_constants.bzl",
        content = """TARGET_LIBC = "{}"
LIBC_VERSION = "{}"
""".format(
            target_libc,
            libc_version,
        ),
    )

_lazy_download_bins = repository_rule(
    implementation = _lazy_download_bins_impl,
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

_eager_declare_toolchain = repository_rule(
    implementation = _eager_declare_toolchain_impl,
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

detect_host_platform = repository_rule(
    implementation = _detect_host_platform_impl,
)

def _cxx_toolchains(module_ctx):
    for mod in module_ctx.modules:
        for declared_toolchain in mod.tags.declare:
            # we need to use a module extension + two repository rules
            # to enable lazy downloading of the toolchain binaries
            # when registering many toolchains.
            # repository rules arent allowed to call other repository rules,
            # so we have to wrap the two repository rules in a module extension.
            # `_eager_declare_toolchain` declares the toolchain(...) which is eagerly evaluated
            # for every registered toolchain. This allows bazel to determime
            # which toolchain is valid for the current platform.
            # `_lazy_download_bins` only downloads the binaries when the toolchain
            # is actually used in a build.
            # more context: https://github.com/reutermj/toolchains_cc.bzl/issues/1
            _eager_declare_toolchain(
                name = declared_toolchain.name,
                vendor = declared_toolchain.vendor,
                cxx_std_lib = declared_toolchain.cxx_std_lib,
            )
            _lazy_download_bins(
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
