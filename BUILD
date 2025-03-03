load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")

cc_toolchain(
    name = "cc_toolchain",
    # TODO
    #    args = select({
    #        "@platforms//os:linux": ["//toolchains/args/linux:args"],
    #        "@platforms//os:windows": ["//toolchains/args/windows:args"],
    #    }),
    enabled_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    known_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    tool_map = "//toolchains:all_tools",
)

toolchain(
    name = "toolchain",
    toolchain = ":cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    visibility = ["//visibility:public"],
)
