load("@rules_cc//cc/toolchains:args.bzl", "cc_args") 
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")
load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")
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

toolchain(
    name = "%{toolchain_name}",
    toolchain = ":host_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "host_cc_toolchain",
    args = [
        ":no-canonical-prefixes",
        ":sysroot-arg",
        ":use_llvm_linker",
        ":use-libcxx",
    ],
    enabled_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    known_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    tool_map = ":all_tools",
)

# Bazel does not like absolute paths. 
# Clang will use absolute paths when reporting the include path for its headers causing bazel to error out.
# This changes clang to prefer relative paths.
# Symptom:
# ERROR: C:/users/mark/desktop/new_toolchain/BUILD:1:10: Compiling main.c failed: absolute path inclusion(s) found in rule '//:main':
# the source file 'main.c' includes the following non-builtin files with absolute paths (if these are builtin files, make sure these paths are in your toolchain):
#   'C:/Users/mark/_bazel_mark/w77p7fta/external/+_repo_rules+llvm_toolchain/toolchain/lib/clang/19/include/vadefs.h'
cc_args(
    name = "no-canonical-prefixes",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["-no-canonical-prefixes"],
)

# by default, clang uses ld.
cc_args(
    name = "use_llvm_linker",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["-fuse-ld=lld"],
)

cc_args(
    name = "use-libcxx",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["-stdlib=libc++"],
)

cc_args(
    name = "sysroot-arg",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["--sysroot={sysroot}"],
    format = {
        "sysroot": ":sysroot"
    },
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
