load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")
load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_files",
    srcs = glob(["**"]),
)

directory(
    name = "root",
    srcs = [":all_files"],
)

subdirectory(
    name = "sysroot",
    parent = ":root",
    path = "sysroot",
)

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
)

cc_tool(
    name = "ar_actions",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/llvm-ar.exe",
        "//conditions:default": ":toolchain/bin/llvm-ar",
    }),
    data = [":all_files"],
)

cc_tool(
    name = "assembly_actions",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/clang++.exe",
        "//conditions:default": ":toolchain/bin/clang++",
    }),
    data = [":all_files"],
)

cc_tool(
    name = "c_compile",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/clang.exe",
        "//conditions:default": ":toolchain/bin/clang",
    }),
    data = [":all_files"],
)

cc_tool(
    name = "cpp_compile_actions",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/clang++.exe",
        "//conditions:default": ":toolchain/bin/clang++",
    }),
    data = [":all_files"],
)

cc_tool(
    name = "link_actions",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/clang++.exe",
        "//conditions:default": ":toolchain/bin/clang++",
    }),
    data = [":all_files"],
)

cc_tool(
    name = "objcopy_embed_data",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/llvm-objcopy.exe",
        "//conditions:default": ":toolchain/bin/llvm-objcopy",
    }),
    data = [":all_files"],
)

cc_tool(
    name = "strip",
    src = select({
        "@platforms//os:windows": ":toolchain/bin/llvm-strip.exe",
        "//conditions:default": ":toolchain/bin/llvm-strip",
    }),
    data = [":all_files"],
)
