load("@rules_cc//cc/toolchains:args.bzl", "cc_args") 
load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")

package(default_visibility = ["//visibility:public"])

toolchain(
    name = "%{toolchain_name}",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@toolchains_cc//vendor:%{vendor}",
        "@toolchains_cc//c++:%{cxx_std_lib}",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":host_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "host_cc_toolchain",
    args = [
        ":no-canonical-prefixes",
        ":target_triple",
        ":sysroot-arg",
        ":use_llvm_linker",
        ":cxx_std_lib",
    ],
    enabled_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    known_features = ["@rules_cc//cc/toolchains/args:experimental_replace_legacy_action_config_features"],
    # the double @ is important, but I dont know why.
    tool_map = "@@%{bins_repo_name}//:all_tools",
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
    name = "cxx_std_lib",
    actions = [
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["-stdlib=%{cxx_std_lib}"],
)

cc_args(
    name = "target_triple",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile_actions",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = ["--target=%{target_triple}"],
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
        "sysroot": "@@%{bins_repo_name}//:sysroot"
    },
)
