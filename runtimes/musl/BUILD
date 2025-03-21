load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":musl": [
                ":arg-include",
                ":arg-lib",
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

alias(
    name = "include",
    actual = select({
        ":musl-latest": "//runtimes/musl/1.2.5:include",
        ":musl-1.2.5": "//runtimes/musl/1.2.5:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":musl-latest": "//runtimes/musl/1.2.5:lib",
        ":musl-1.2.5": "//runtimes/musl/1.2.5:lib",
    }),
)

selects.config_setting_group(
    name = "musl",
    match_any = [
        ":musl-latest",
        ":musl-1.2.5",
    ],
)

config_setting(
    name = "musl-shared-latest",
    flag_values = {
        "//:use_runtimes": "musl",
    },
)
config_setting(
    name = "musl-static-latest",
    flag_values = {
        "//:use_runtimes": "musl-static",
    },
)
selects.config_setting_group(
    name = "musl-latest",
    match_any = [
        ":musl-shared-latest",
        ":musl-static-latest",
    ],
)
config_setting(
    name = "musl-shared-1.2.5",
    flag_values = {
        "//:use_runtimes": "musl-1.2.5",
    },
)
config_setting(
    name = "musl-static-1.2.5",
    flag_values = {
        "//:use_runtimes": "musl-static-1.2.5",
    },
)
selects.config_setting_group(
    name = "musl-1.2.5",
    match_any = [
        ":musl-shared-1.2.5",
        ":musl-static-1.2.5",
    ],
)
