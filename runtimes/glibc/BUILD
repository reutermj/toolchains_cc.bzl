load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({
            ":glibc": [
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
        ":glibc-shared": [
            "-fuse-ld=lld",
            "-lc",
            "{lib}/libc_nonshared.a",
        ],
        ":glibc-static": [
            "-fuse-ld=lld",
            "{lib}/libc.a",
            "{lib}/libc_nonshared.a",
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
        ":glibc-shared": [
            "{lib}/crt1.o",
            "{lib}/crti.o",
            "{lib}/crtn.o",
        ],
        ":glibc-static": [
            "{lib}/crt1.o",
            "{lib}/crti.o",
            "{lib}/crtn.o",
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
        ":glibc-latest": "//runtimes/glibc/2.27:include",
        ":glibc-2.27": "//runtimes/glibc/2.27:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        ":glibc-latest": "//runtimes/glibc/2.27:lib",
        ":glibc-2.27": "//runtimes/glibc/2.27:lib",
    }),
)

selects.config_setting_group(
    name = "glibc",
    match_any = [
        ":glibc-latest",
        ":glibc-2.27",
    ],
)

selects.config_setting_group(
    name = "glibc-shared",
    match_any = [
        ":glibc-shared-latest",
        ":glibc-shared-2.27",
    ],
)

selects.config_setting_group(
    name = "glibc-static",
    match_any = [
        ":glibc-static-latest",
        ":glibc-static-2.27",
    ],
)

selects.config_setting_group(
    name = "glibc-latest",
    match_any = [
        ":glibc-shared-latest",
        ":glibc-static-latest",
    ],
)

config_setting(
    name = "glibc-shared-latest",
    flag_values = {
        "//:use_runtimes": "glibc",
    },
)

config_setting(
    name = "glibc-static-latest",
    flag_values = {
        "//:use_runtimes": "glibc-static",
    },
)

selects.config_setting_group(
    name = "glibc-2.27",
    match_any = [
        ":glibc-shared-2.27",
        ":glibc-static-2.27",
    ],
)

config_setting(
    name = "glibc-shared-2.27",
    flag_values = {
        "//:use_runtimes": "glibc-2.27",
    },
)

config_setting(
    name = "glibc-static-2.27",
    flag_values = {
        "//:use_runtimes": "glibc-static-2.27",
    },
)
