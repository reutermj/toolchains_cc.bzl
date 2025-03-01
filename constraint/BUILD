load("@bazel_skylib//lib:selects.bzl", "selects")

selects.config_setting_group(
    name = "linux_x86_64",
    match_all = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

selects.config_setting_group(
    name = "linux_aarch64",
    match_all = [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
)

selects.config_setting_group(
    name = "macos_x86_64",
    match_all = [
        "@platforms//os:macos",
        "@platforms//cpu:x86_64",
    ],
)

selects.config_setting_group(
    name = "macos_aarch64",
    match_all = [
        "@platforms//os:macos",
        "@platforms//cpu:aarch64",
    ],
)

selects.config_setting_group(
    name = "windows_x86_64",
    match_all = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
)

selects.config_setting_group(
    name = "windows_aarch64",
    match_all = [
        "@platforms//os:windows",
        "@platforms//cpu:aarch64",
    ],
)
