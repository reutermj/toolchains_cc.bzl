load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

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

subdirectory(
    name = "lib",
    parent = ":root",
    path = "lib",
    visibility = ["//visibility:public"],
)
