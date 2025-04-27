package(default_visibility = ["//:__subpackages__"])

alias(
    name = "include",
    actual = select({
        "//constraint:windows_aarch64": "@msvc-14.43.34808-windows-aarch64//:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        "//constraint:windows_aarch64": "@msvc-14.43.34808-windows-aarch64//:lib",
    }),
)
