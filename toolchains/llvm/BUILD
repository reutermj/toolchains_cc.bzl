package(default_visibility = ["//:__subpackages__"])

alias(
    name = "ar_actions",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:ar_actions",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:ar_actions",
    })
)
alias(
    name = "assembly_actions",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:assembly_actions",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:assembly_actions",
    })
)
alias(
    name = "c_compile",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:c_compile",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:c_compile",
    })
)
alias(
    name = "cpp_compile_actions",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:cpp_compile_actions",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:cpp_compile_actions",
    })
)
alias(
    name = "link_actions",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:link_actions",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:link_actions",
    })
)
alias(
    name = "link_data",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:link_data",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:link_data",
    })
)
alias(
    name = "objcopy_embed_data",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:objcopy_embed_data",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:objcopy_embed_data",
    })
)
alias(
    name = "strip",
    actual = select({
        "//toolchains:latest": "//toolchains/llvm/19.1.7:strip",
        "//toolchains:19.1.7": "//toolchains/llvm/19.1.7:strip",
    })
)
