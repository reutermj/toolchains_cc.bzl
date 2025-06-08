load("@toolchains_cc_host_platform_constants//:platform_constants.bzl", "TARGET_LIBC")

package(default_visibility = ["//visibility:public"])

constraint_setting(
    name = "vendor",
    default_constraint_value = TARGET_LIBC,
)

constraint_value(
    name = "ubuntu",
    constraint_setting = ":vendor",
)

constraint_value(
    name = "alpine",
    constraint_setting = ":vendor",
)
