package(default_visibility = ["//:__subpackages__"])

alias(
    name = "include",
    actual = select({
        "//constraint:linux_x86_64": "@linux-libc-dev-5.4.0-linux-x86_64//:include",
    }),
)

alias(
    name = "lib",
    actual = select({
        "//constraint:linux_x86_64": "@linux-libc-dev-5.4.0-linux-x86_64//:lib",
    }),
)
