package(default_visibility = ["//:__subpackages__"])

alias(
    name = "include",
    actual = select({
        "//constraint:linux_x86_64": "@glibc-2.31-linux-x86_64//:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        "//constraint:linux_x86_64": "@glibc-2.31-linux-x86_64//:lib",
    }),
)
