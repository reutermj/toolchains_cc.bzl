load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

package(default_visibility = ["//toolchain:__subpackages__"])

cc_args_list(
    name = "args",
    args =
        select({{
            ":{name}": [
                ":llvm-c_compile",
                ":llvm-cpp_compile_actions",
                ":llvm-link_actions",
                ":arg-include",
            ],
            "//conditions:default": [],
        }}),
    visibility = ["//toolchain:__pkg__"],
)

cc_args(
    name = "arg-include",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
    ],
    args = [
        "-isystem",
        "{{include}}",
    ],
    data = [
        ":include",
    ],
    format = {{
        "include": ":include",
    }},
)

