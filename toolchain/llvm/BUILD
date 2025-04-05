load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

package(default_visibility = ["//toolchain:__subpackages__"])

cc_args_list(
    name = "args",
    args =
        select({
            ":llvm": [
                ":llvm-c_compile",
                ":llvm-cpp_compile_actions",
                ":llvm-link_actions",
            ],
            "//conditions:default": [],
        }),
    visibility = ["//toolchain:__pkg__"],
)

cc_args(
    name = "llvm-c_compile",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
    ],
    args = select({
        "@platforms//os:linux": [
            "-nostdinc",
            "-nostdlib",
            "-nodefaultlibs",
        ],
    }),
)

cc_args(
    name = "llvm-cpp_compile_actions",
    actions = [
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
    ],
    args = select({
        "@platforms//os:linux": [
            "-nostdinc",
            "-nostdlib",
            "-nodefaultlibs",
            "-nostdinc++",
            "-nostdlib++",
        ],
    }),
)

cc_args(
    name = "llvm-link_actions",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = select({
        "@platforms//os:linux": [
            "-nostdinc",
            "-nostdlib",
            "-nodefaultlibs",
            "-nostdinc++",
            "-nostdlib++",
        ],
    }),
)

alias(
    name = "ar_actions",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:ar_actions",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:ar_actions",
    }),
)

alias(
    name = "assembly_actions",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:assembly_actions",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:assembly_actions",
    }),
)

alias(
    name = "c_compile",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:c_compile",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:c_compile",
    }),
)

alias(
    name = "cpp_compile_actions",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:cpp_compile_actions",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:cpp_compile_actions",
    }),
)

alias(
    name = "link_actions",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:link_actions",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:link_actions",
    }),
)

alias(
    name = "link_data",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:link_data",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:link_data",
    }),
)

alias(
    name = "objcopy_embed_data",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:objcopy_embed_data",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:objcopy_embed_data",
    }),
)

alias(
    name = "strip",
    actual = select({
        ":llvm-latest": "//toolchain/llvm/19.1.7:strip",
        ":llvm-19.1.7": "//toolchain/llvm/19.1.7:strip",
    }),
)

selects.config_setting_group(
    name = "llvm",
    match_any = [
        ":llvm-latest",
        ":llvm-19.1.7",
    ],
)

config_setting(
    name = "llvm-latest",
    flag_values = {
        "//:use_toolchain": "llvm",
    },
)

config_setting(
    name = "llvm-19.1.7",
    flag_values = {
        "//:use_toolchain": "llvm-19.1.7",
    },
)
