load("@bazel_skylib//rules:common_settings.bzl", "string_flag", "string_list_flag")
load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")

cc_toolchain(
    name = "toolchains_cc_toolchain",
    args = ["//runtimes:args"],
    enabled_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    known_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    tool_map = "//toolchain:all_tools",
)

toolchain(
    name = "toolchains_cc",
    toolchain = ":toolchains_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    visibility = ["//visibility:public"],
)

string_flag(
    name = "use_toolchain",
    build_setting_default = "llvm",
    visibility = ["//visibility:public"],
)

string_list_flag(
    name = "use_runtimes",
    build_setting_default = ["musl"],
    visibility = ["//visibility:public"],
)
