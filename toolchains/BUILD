load("@bazel_skylib//rules:common_settings.bzl", "string_flag")
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")

cc_tool_map(
    name = "all_tools",
    tools = {
        "@rules_cc//cc/toolchains/actions:ar_actions": ":ar_actions",
        "@rules_cc//cc/toolchains/actions:assembly_actions": ":assembly_actions",
        "@rules_cc//cc/toolchains/actions:c_compile": ":c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions": ":cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions": ":link_actions",
        "@rules_cc//cc/toolchains/actions:objcopy_embed_data": ":objcopy_embed_data",
        "@rules_cc//cc/toolchains/actions:strip": ":strip",
    },
    visibility = ["//:__subpackages__"],
)

cc_tool(
    name = "ar_actions",
    src = select({
        ":clang": "//toolchains/clang:ar_actions",
    }),
)

cc_tool(
    name = "assembly_actions",
    src = select({
        ":clang": "//toolchains/clang:assembly_actions",
    }),
)

cc_tool(
    name = "c_compile",
    src = select({
        ":clang": "//toolchains/clang:c_compile",
    }),
)

cc_tool(
    name = "cpp_compile_actions",
    src = select({
        ":clang": "//toolchains/clang:cpp_compile_actions",
    }),
)

cc_tool(
    name = "link_actions",
    src = select({
        ":clang": "//toolchains/clang:link_actions",
    }),
    data = select({
        ":clang": ["//toolchains/clang:link_data"],
    }),
)

cc_tool(
    name = "objcopy_embed_data",
    src = select({
        ":clang": "//toolchains/clang:objcopy_embed_data",
    }),
)

cc_tool(
    name = "strip",
    src = select({
        ":clang": "//toolchains/clang:strip",
    }),
)

string_flag(
    name = "toolchain",
    build_setting_default = "clang",
)

config_setting(
    name = "clang",
    flag_values = {
        "//toolchains:toolchain": "clang",
    },
)

string_flag(
    name = "version",
    build_setting_default = "latest",
)

config_setting(
    name = "latest",
    flag_values = {
        "//toolchains:version": "latest",
    },
)

config_setting(
    name = "19.1.7",
    flag_values = {
        "//toolchains:version": "19.1.7",
    },
)
