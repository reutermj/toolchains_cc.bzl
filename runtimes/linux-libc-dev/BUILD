load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":linux-libc-dev": [
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
        ":linux-libc-dev-latest": "//runtimes/linux-libc-dev/5.4.0:include",
        ":linux-libc-dev-5.4.0": "//runtimes/linux-libc-dev/5.4.0:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":linux-libc-dev-latest": "//runtimes/linux-libc-dev/5.4.0:lib",
        ":linux-libc-dev-5.4.0": "//runtimes/linux-libc-dev/5.4.0:lib",
    }),
)

selects.config_setting_group(
    name = "linux-libc-dev",
    match_any = [
        ":linux-libc-dev-latest",
        ":linux-libc-dev-5.4.0",
    ],
)

config_setting(
    name = "linux-libc-dev-latest",
    flag_values = {
        "//:use_runtimes": "linux-libc-dev",
    },
)

config_setting(
    name = "linux-libc-dev-5.4.0",
    flag_values = {
        "//:use_runtimes": "linux-libc-dev-5.4.0",
    },
)
