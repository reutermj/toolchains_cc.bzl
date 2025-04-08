load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":libcxx": [
                ":arg-include",
                ":arg-lib",
                ":link_actions",
                ":link_executable_actions",
            ],
            "//conditions:default": [],
        }),
    visibility = ["//runtimes:__pkg__"],
)

cc_args(
    name = "arg-include",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
    ],
    args = [
        "-isystem",
        "{include}",
    ],
    data = [
        ":include",
    ],
    format = {
        "include": ":include",
    },
)

cc_args(
    name = "arg-lib",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = [
        "-L{lib}",
    ],
    data = [
        ":lib",
    ],
    format = {
        "lib": ":lib",
    },
)

cc_args(
    name = "link_actions",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = select({
        ":libcxx-shared": [
            "-L{lib}",
            "-lc++",
            "-lc++abi",
            "-lunwind",
            "-llzma",
        ],
        ":libcxx-static": [
            "{lib}/libc++.a",
            "{lib}/libc++abi.a",
            "{lib}/libunwind.a",
            "{lib}/liblzma.a",
        ],
    }),
    data = [
        ":lib",
    ],
    format = {
        "lib": ":lib",
    },
)

cc_args(
    name = "link_executable_actions",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_executable_actions",
    ],
    args = select({
        ":libcxx-shared": [
            "-L{lib}",
        ],
        ":libcxx-static": [
            "-L{lib}",
        ],
    }),
    data = [
        ":lib",
    ],
    format = {
        "lib": ":lib",
    },
)

alias(
    name = "include",
    actual = select({
        ":libcxx-latest": "//runtimes/libcxx/19.1.7:include",
        ":libcxx-19.1.7": "//runtimes/libcxx/19.1.7:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":libcxx-latest": "//runtimes/libcxx/19.1.7:lib",
        ":libcxx-19.1.7": "//runtimes/libcxx/19.1.7:lib",
    }),
)

selects.config_setting_group(
    name = "libcxx",
    match_any = [
        ":libcxx-latest",
        ":libcxx-19.1.7",
    ],
)

selects.config_setting_group(
    name = "libcxx-shared",
    match_any = [
        ":libcxx-shared-latest",
        ":libcxx-shared-19.1.7",
    ],
)

selects.config_setting_group(
    name = "libcxx-static",
    match_any = [
        ":libcxx-static-latest",
        ":libcxx-static-19.1.7",
    ],
)

selects.config_setting_group(
    name = "libcxx-latest",
    match_any = [
        ":libcxx-shared-latest",
        ":libcxx-static-latest",
    ],
)

config_setting(
    name = "libcxx-shared-latest",
    flag_values = {
        "//:use_runtimes": "libcxx",
    },
)

config_setting(
    name = "libcxx-static-latest",
    flag_values = {
        "//:use_runtimes": "libcxx-static",
    },
)

selects.config_setting_group(
    name = "libcxx-19.1.7",
    match_any = [
        ":libcxx-shared-19.1.7",
        ":libcxx-static-19.1.7",
    ],
)

config_setting(
    name = "libcxx-shared-19.1.7",
    flag_values = {
        "//:use_runtimes": "libcxx-19.1.7",
    },
)

config_setting(
    name = "libcxx-static-19.1.7",
    flag_values = {
        "//:use_runtimes": "libcxx-static-19.1.7",
    },
)
