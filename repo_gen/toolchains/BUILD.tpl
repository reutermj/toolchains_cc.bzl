load("@bazel_skylib//lib:selects.bzl", "selects")

package(default_visibility = ["//toolchains:__subpackages__"])
{version_aliases}
{config_setting_group}
config_setting(
    name = "{name}-latest",
    flag_values = {{
        "//:use_toolchain": "{name}",
    }},
)

{version_configs}
