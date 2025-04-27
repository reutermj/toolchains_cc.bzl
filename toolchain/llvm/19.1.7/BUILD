package(default_visibility = ["//:__subpackages__"])

alias(
    name = "ar_actions",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:ar_actions",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:ar_actions",
    }),
)

alias(
    name = "assembly_actions",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:assembly_actions",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:assembly_actions",
    }),
)

alias(
    name = "c_compile",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:c_compile",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:c_compile",
    }),
)

alias(
    name = "cpp_compile_actions",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:cpp_compile_actions",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:cpp_compile_actions",
    }),
)

alias(
    name = "link_actions",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:link_actions",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:link_actions",
    }),
)

alias(
    name = "link_data",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:link_data",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:link_data",
    }),
)

alias(
    name = "objcopy_embed_data",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:objcopy_embed_data",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:objcopy_embed_data",
    }),
)

alias(
    name = "strip",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:strip",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:strip",
    }),
)

alias(
    name = "include",
    actual = select({
        "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:include",
        "//constraint:windows_aarch64": "@llvm-19.1.7-windows-aarch64//:include",
    }),
)
