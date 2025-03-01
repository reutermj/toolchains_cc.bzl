"Your one stop shop for hermetic c/c++ toolchains in Bazel!"
module(name = "toolchains_cc")

bazel_dep(name = "rules_cc", version = "0.1.1")
bazel_dep(name = "bazel_skylib", version = "1.7.1")
bazel_dep(name = "platforms", version = "0.0.11")

# Problem: Even with xz compression, the total bin size for all the platforms is still quite large.
#          We prioritize minimizing the size of downloaded bins in CI.
# Solution: Split the platforms and individual toolchain distributions into multiple archives to only download what is required.
http_archive = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Clang Linux x86_64
{clang_linux_x86_64}