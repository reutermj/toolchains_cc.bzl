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
        ":musl-latest": "//runtimes/musl/1.2.5-r10:include",
        ":musl-1.2.5-r10": "//runtimes/musl/1.2.5-r10:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":musl-latest": "//runtimes/musl/1.2.5-r10:lib",
        ":musl-1.2.5-r10": "//runtimes/musl/1.2.5-r10:lib",
    }),
)

selects.config_setting_group(
    name = "musl",
    match_any = [
        ":musl-latest",
        ":musl-1.2.5-r10",
    ],
)

config_setting(
    name = "musl-latest",
    flag_values = {
        "//:use_runtimes": "musl",
    },
)

config_setting(
    name = "musl-1.2.5-r10",
    flag_values = {
        "//:use_runtimes": "musl-1.2.5-r10",
    },
)
