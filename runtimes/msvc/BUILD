load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":msvc": [
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
        ":msvc-shared": [
            "-L{lib}",
            "-llibcmt",
            "-llibcpmt",
            "-loldnames",
        ],
        ":msvc-static": [
            "-L{lib}",
            "-llibcmt",
            "-llibcpmt",
            "-loldnames",
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
        ":msvc-shared": [
            "-L{lib}",
        ],
        ":msvc-static": [
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
        ":msvc-latest": "//runtimes/msvc/14.43.34808:include",
        ":msvc-14.43.34808": "//runtimes/msvc/14.43.34808:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":msvc-latest": "//runtimes/msvc/14.43.34808:lib",
        ":msvc-14.43.34808": "//runtimes/msvc/14.43.34808:lib",
    }),
)

selects.config_setting_group(
    name = "msvc",
    match_any = [
        ":msvc-latest",
        ":msvc-14.43.34808",
    ],
)

selects.config_setting_group(
    name = "msvc-shared",
    match_any = [
        ":msvc-shared-latest",
        ":msvc-shared-14.43.34808",
    ],
)

selects.config_setting_group(
    name = "msvc-static",
    match_any = [
        ":msvc-static-latest",
        ":msvc-static-14.43.34808",
    ],
)

selects.config_setting_group(
    name = "msvc-latest",
    match_any = [
        ":msvc-shared-latest",
        ":msvc-static-latest",
    ],
)

config_setting(
    name = "msvc-shared-latest",
    flag_values = {
        "//:use_runtimes": "msvc",
    },
)

config_setting(
    name = "msvc-static-latest",
    flag_values = {
        "//:use_runtimes": "msvc-static",
    },
)

selects.config_setting_group(
    name = "msvc-14.43.34808",
    match_any = [
        ":msvc-shared-14.43.34808",
        ":msvc-static-14.43.34808",
    ],
)

config_setting(
    name = "msvc-shared-14.43.34808",
    flag_values = {
        "//:use_runtimes": "msvc-14.43.34808",
    },
)

config_setting(
    name = "msvc-static-14.43.34808",
    flag_values = {
        "//:use_runtimes": "msvc-static-14.43.34808",
    },
)
