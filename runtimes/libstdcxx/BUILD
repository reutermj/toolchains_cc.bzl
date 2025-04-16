load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":libstdcxx": [
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
        ":libstdcxx-shared": [
            "-L{lib}",
            "-lstdc++",
        ],
        ":libstdcxx-static": [
            "{lib}/libstdc++.a",
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
        ":libstdcxx-shared": [
            "-L{lib}",
        ],
        ":libstdcxx-static": [
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
        ":libstdcxx-latest": "//runtimes/libstdcxx/10.5.0:include",
        ":libstdcxx-10.5.0": "//runtimes/libstdcxx/10.5.0:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":libstdcxx-latest": "//runtimes/libstdcxx/10.5.0:lib",
        ":libstdcxx-10.5.0": "//runtimes/libstdcxx/10.5.0:lib",
    }),
)

selects.config_setting_group(
    name = "libstdcxx",
    match_any = [
        ":libstdcxx-latest",
        ":libstdcxx-10.5.0",
    ],
)

selects.config_setting_group(
    name = "libstdcxx-shared",
    match_any = [
        ":libstdcxx-shared-latest",
        ":libstdcxx-shared-10.5.0",
    ],
)

selects.config_setting_group(
    name = "libstdcxx-static",
    match_any = [
        ":libstdcxx-static-latest",
        ":libstdcxx-static-10.5.0",
    ],
)

selects.config_setting_group(
    name = "libstdcxx-latest",
    match_any = [
        ":libstdcxx-shared-latest",
        ":libstdcxx-static-latest",
    ],
)

config_setting(
    name = "libstdcxx-shared-latest",
    flag_values = {
        "//:use_runtimes": "libstdcxx",
    },
)

config_setting(
    name = "libstdcxx-static-latest",
    flag_values = {
        "//:use_runtimes": "libstdcxx-static",
    },
)

selects.config_setting_group(
    name = "libstdcxx-10.5.0",
    match_any = [
        ":libstdcxx-shared-10.5.0",
        ":libstdcxx-static-10.5.0",
    ],
)

config_setting(
    name = "libstdcxx-shared-10.5.0",
    flag_values = {
        "//:use_runtimes": "libstdcxx-10.5.0",
    },
)

config_setting(
    name = "libstdcxx-static-10.5.0",
    flag_values = {
        "//:use_runtimes": "libstdcxx-static-10.5.0",
    },
)
