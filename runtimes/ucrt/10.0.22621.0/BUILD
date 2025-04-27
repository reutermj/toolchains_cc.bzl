package(default_visibility = ["//:__subpackages__"])

alias(
    name = "include",
    actual = select({
        "//constraint:windows_aarch64": "@ucrt-10.0.22621.0-windows-aarch64//:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        "//constraint:windows_aarch64": "@ucrt-10.0.22621.0-windows-aarch64//:lib",
    }),
)
