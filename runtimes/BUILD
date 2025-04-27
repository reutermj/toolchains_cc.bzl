load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")

# for cc_args, you need to set both the data and format fields
# with just the format field set, bazel wont pull the runtime dependencies into the sandbox.
# symptoms of this issue are missing headers/libs during the build, and
# with `-v` enabled, you see things like this in clang:
# ignoring nonexistent directory "external/toolchains_cc++_repo_rules+musl-1.2.5-r8-linux-x86_64/include"

cc_args_list(
    name = "args",
    args = [
        # ordering is important:
        # 1. c++ args
        # 2. toolchain args
        # 3. c args
        "//runtimes/msvc:args",
        "//runtimes/libcxx:args",
        "//runtimes/libstdcxx:args",
        "//toolchain:args",
        "//runtimes/glibc:args",
        "//runtimes/musl:args",
        "//runtimes/ucrt:args",
        "//runtimes/linux-libc-dev:args",
    ],
    visibility = ["//:__pkg__"],
)
