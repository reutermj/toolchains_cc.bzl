load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

cc_args_list(
    name = "args",
    args =
        select({{
            ":{name}": [
                ":arg-include",
                ":arg-lib",
                ":link_actions",
                ":link_executable_actions",
            ],
            "//conditions:default": [],
        }}),
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
        "{{include}}",
    ],
    data = [
        ":include",
    ],
    format = {{
        "include": ":include",
    }},
)

cc_args(
    name = "arg-lib",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = [
        "-L{{lib}}",
    ],
    data = [
        ":lib",
    ],
    format = {{
        "lib": ":lib",
    }},
)
{link_args}
{version_aliases}
{config_setting_group}
{version_configs}
