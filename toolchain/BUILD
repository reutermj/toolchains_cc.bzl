load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")

cc_args_list(
    name = "args",
    args = [
        "//toolchain/llvm:args",
    ],
    visibility = ["//:__subpackages__"],
)

cc_tool_map(
    name = "all_tools",
    tools = {
        "@rules_cc//cc/toolchains/actions:ar_actions": ":ar_actions",
        "@rules_cc//cc/toolchains/actions:assembly_actions": ":assembly_actions",
        "@rules_cc//cc/toolchains/actions:c_compile": ":c_compile",
        "@rules_cc//cc/toolchains/actions:cpp_compile_actions": ":cpp_compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions": ":link_actions",
        "@rules_cc//cc/toolchains/actions:objcopy_embed_data": ":objcopy_embed_data",
        "@rules_cc//cc/toolchains/actions:strip": ":strip",
    },
    visibility = ["//:__subpackages__"],
)

cc_tool(
    name = "ar_actions",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:ar_actions",
    }),
)

cc_tool(
    name = "assembly_actions",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:assembly_actions",
    }),
)

cc_tool(
    name = "c_compile",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:c_compile",
    }),
)

cc_tool(
    name = "cpp_compile_actions",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:cpp_compile_actions",
    }),
)

cc_tool(
    name = "link_actions",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:link_actions",
    }),
    data = select({
        "//toolchain/llvm:llvm": ["//toolchain/llvm:link_data"],
    }),
)

cc_tool(
    name = "objcopy_embed_data",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:objcopy_embed_data",
    }),
)

cc_tool(
    name = "strip",
    src = select({
        "//toolchain/llvm:llvm": "//toolchain/llvm:strip",
    }),
)
