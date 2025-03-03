# toolchains_cc

Your one stop shop for default, hermetic c/c++ toolchains in Bazel!

This package:
* is easy to configure,
* supports linux, macos, and windows bazel builds,
* supports clang, gcc, and msvc compiler toolchains,
* supports x86_64 and arm64,
* has low overhead on CI runs, and
* enables remote caching to further speed up your development and CI.

## Show me the code

Add two lines to your `MODULE.bazel` and it just works:

```
bazel_dep(name = "toolchains_cc")
register_toolchains("@toolchains_cc//:toolchain", dev_dependency = True)
```

Check out the [full example here](examples/hello_world).