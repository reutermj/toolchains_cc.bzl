load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

# for cc_args, you need to set both the data and format fields
# with just the format field set, bazel wont pull the runtime dependencies into the sandbox.
# symptoms of this issue are missing headers/libs during the build, and
# with `-v` enabled, you see things like this in clang:
# ignoring nonexistent directory "external/toolchains_cc++_repo_rules+musl-1.2.5-r8-linux-x86_64/include"

cc_args_list(
    name = "args",
    args = [
        ":nostd",
        ":nostd++",
        ":nostd_link",
        "//runtimes/musl:args",
    ],
    visibility = ["//:__pkg__"],
)

cc_args(
    name = "nostd",
    actions = [
        "@rules_cc//cc/toolchains/actions:c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
    ],
    args = [
        "-nostdinc",
        "-nostdlib",
        "-nodefaultlibs",
    ],
    visibility = ["//visibility:public"],
)

cc_args(
    name = "nostd++",
    actions = [
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions",
    ],
    args = [
        "-nostdinc++",
        "-nostdlib++",
    ],
    visibility = ["//visibility:public"],
)

cc_args(
    name = "nostd_link",
    actions = [
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = [
        "-nostdinc",
        "-nostdlib",
        "-nodefaultlibs",
        "-nostdinc++",
        "-nostdlib++",
    ],
    visibility = ["//visibility:public"],
)
