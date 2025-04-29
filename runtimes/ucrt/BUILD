load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":ucrt": [
                ":arg-include",
                ":arg-lib",
                ":link_actions",
                ":link_executable_actions",
            ],
            "//conditions:default": [
                ":no-op"
            ],
        }),
    visibility = ["//runtimes:__pkg__"],
)

cc_args(
    name = "no-op",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
    ],
    args = [
        "-isystem",
        "path/does/not/exist",
    ],
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
        ":ucrt-shared": [
            "-L{lib}",
            "-fuse-ld=lld",
            "-llibucrt",
        ],
        ":ucrt-static": [
            "-L{lib}",
            "-fuse-ld=lld",
            "-llibucrt",
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
        ":ucrt-shared": [
            "-L{lib}",
        ],
        ":ucrt-static": [
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
        ":ucrt-latest": "//runtimes/ucrt/10.0.22621.0:include",
        ":ucrt-10.0.22621.0": "//runtimes/ucrt/10.0.22621.0:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":ucrt-latest": "//runtimes/ucrt/10.0.22621.0:lib",
        ":ucrt-10.0.22621.0": "//runtimes/ucrt/10.0.22621.0:lib",
    }),
)

selects.config_setting_group(
    name = "ucrt",
    match_any = [
        ":ucrt-latest",
        ":ucrt-10.0.22621.0",
    ],
)

selects.config_setting_group(
    name = "ucrt-shared",
    match_any = [
        ":ucrt-shared-latest",
        ":ucrt-shared-10.0.22621.0",
    ],
)

selects.config_setting_group(
    name = "ucrt-static",
    match_any = [
        ":ucrt-static-latest",
        ":ucrt-static-10.0.22621.0",
    ],
)

selects.config_setting_group(
    name = "ucrt-latest",
    match_any = [
        ":ucrt-shared-latest",
        ":ucrt-static-latest",
    ],
)

config_setting(
    name = "ucrt-shared-latest",
    flag_values = {
        "//:use_runtimes": "ucrt",
    },
)

config_setting(
    name = "ucrt-static-latest",
    flag_values = {
        "//:use_runtimes": "ucrt-static",
    },
)

selects.config_setting_group(
    name = "ucrt-10.0.22621.0",
    match_any = [
        ":ucrt-shared-10.0.22621.0",
        ":ucrt-static-10.0.22621.0",
    ],
)

config_setting(
    name = "ucrt-shared-10.0.22621.0",
    flag_values = {
        "//:use_runtimes": "ucrt-10.0.22621.0",
    },
)

config_setting(
    name = "ucrt-static-10.0.22621.0",
    flag_values = {
        "//:use_runtimes": "ucrt-static-10.0.22621.0",
    },
)
