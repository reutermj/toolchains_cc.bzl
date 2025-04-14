load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all-files",
    srcs = glob(["**"]),
)

directory(
    name = "root",
    srcs = [":all-files"],
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "include",
    parent = ":root",
    path = "include",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar_actions",
    actual = ":llvm-ar",
)

alias(
    name = "assembly_actions",
    actual = ":clang++",
)

alias(
    name = "c_compile",
    actual = ":clang",
)

alias(
    name = "cpp_compile_actions",
    actual = ":clang++",
)

alias(
    name = "link_actions",
    actual = ":clang++",
)

filegroup(
    name = "link_data",
    srcs = [
        ":ld.lld",
        ":ld64.lld",
        ":lld",
        ":lld-link",
    ],
)

alias(
    name = "objcopy_embed_data",
    actual = ":llvm-objcopy",
)

alias(
    name = "strip",
    actual = ":llvm-strip",
)
