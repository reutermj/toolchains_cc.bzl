import os
import json

def get_configurations(dir):
    with open(f'repo_gen/{dir}.json', 'r') as file:
        rows = json.load(file)
    
    return rows


# Used to create a single config line in a select nested in an alias
# Example:
# alias(
#     name = "include",
#     actual = select({
#         ":musl-latest": "//runtimes/musl/1.2.5:include", # used to generate this line
#         ":musl-1.2.5": "//runtimes/musl/1.2.5:include",  # or this line
#     }),
# )
def create_single_select_config(condition, target):
    eight_spaces = "        "
    return f"{eight_spaces}\"{condition}\": \"{target}\",\n"

# Used to create a single label for various things
# Example:
# selects.config_setting_group(
#     name = "musl",
#     match_any = [
#         ":musl-latest", # used to generate this line
#         ":musl-1.2.5",  # or this line
#     ],
# )
def create_single_label(label, num_spaces):
    spaces = " " * num_spaces
    return f"{spaces}\"{label}\",\n"

# ===============
# || Templates ||
# ===============
http_archive_tpl = """
http_archive(
    name = "{type}-{version}-{target_os}-{arch}",
    url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/{artifact_name}",
    sha256 = "{sha}",
)
""".lstrip()

config_setting_tpl = """
config_setting(
    name = "{name}",
    flag_values = {{
        "//:{config}": "{value}",
    }},
)

""".lstrip()

config_settings_group_tpl = """
selects.config_setting_group(
    name = "{name}",
    match_any = [
        {targets}
    ],
)

""".lstrip()

alias_tpl = """
alias(
    name = "{action}",
    actual = select({{
        {conditions}
    }}),
)

""".lstrip()

link_arg_tpl = """
cc_args(
    name = "{link_action}",
    actions = [
        "@rules_cc//cc/toolchains/actions:{link_action}",
    ],
    args = select({{
        {link_args}
    }}),
    data = [
        ":lib",
    ],
    format = {{
        "lib": ":lib",
    }},
)

""".lstrip()

# ==================
# || MODULE.bazel ||
# ==================
# This creates the http_archive rules for each toolchain/runtime
# example outputs:
# http_archive(
#     name = "llvm-19.1.7-linux-x86_64",
#     url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/llvm-19.1.7-linux-x86_64.tar.xz",
#     sha256 = "ac027eb9f1cde6364d063fe91bd299937eb03b8d906f7ddde639cf65b4872cb3",
# )
# ...
# http_archive(
#     name = "musl-1.2.5-linux-x86_64",
#     url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/musl-1.2.5-r10-linux-x86_64.tar.xz",
#     sha256 = "5c2ba292f20013f34f6553000171f488c38bcd497472fd0586d2374c447423ff",
# )
def create_http_archives(rows):
    archives = ""
    for row in rows:
        for version_item in row["versions"]:
            for target_os_item in version_item["oses"]:
                for arch_item in target_os_item["archs"]:
                    archives += http_archive_tpl.format(
                        type=row["name"],
                        version=version_item["version"],
                        target_os=target_os_item["name"],
                        arch=arch_item["name"],
                        sha=arch_item["sha256"],
                        artifact_name=arch_item["artifact-name"]
                    )
    return archives

def generate_module():
    with open('repo_gen/MODULE.bazel.tpl', 'r') as file:
        module_tpl = file.read()
    
    archives = create_http_archives(get_configurations('toolchain'))
    archives += create_http_archives(get_configurations('runtimes'))

    module = module_tpl.format(archives = archives.strip())
    with open('MODULE.bazel', 'w') as file:
        file.write(module)

# =================
# || BUILD files ||
# =================
def create_latest(row, dir):
    name = row["name"]

    if "configurations" not in row:
        return config_setting_tpl.format(
            name=f"{name}-latest",
            value=f"{name}",
            config=f"use_{dir}",
        )
    
    settings = ""
    configs = []
    for config_item in row["configurations"]:
        config = config_item["name"]
        config_name = f"{name}-{config}-latest"
        configs.append(config_name)

    version_tags = ""
    for config in configs:
        version_tags += f"        \":{config}\",\n"
    
    settings += config_settings_group_tpl.format(
        name=f"{name}-latest",
        targets=version_tags.strip()
    )
    return settings

def create_latest_with_configurations(row, dir):
    if "configurations" not in row:
        return ""
    
    name = row["name"]
    default_config = row["default-configuration"]

    settings = ""
    for config_item in row["configurations"]:
        config = config_item["name"]
        config_name = f"{name}-{config}-latest"
        if config == default_config:
            settings += config_setting_tpl.format(
                name=config_name,
                value=f"{name}",
                config=f"use_{dir}",
            )
        else:
            settings += config_setting_tpl.format(
                name=config_name,
                value=f"{name}-{config}",
                config=f"use_{dir}",
            )
    return settings

def create_version(row):
    name = row["name"]

    settings = ""
    for version_item in row["versions"]:
        version = version_item["version"]
        if "configurations" in row:
            configs = []
            for config_item in row["configurations"]:
                config = config_item["name"]
                config_name = f"{name}-{config}-{version}"
                configs.append(config_name)
            
            version_tags = ""
            for config in configs:
                version_tags += create_single_label(f":{config}", 8)
            
            settings += config_settings_group_tpl.format(
                name=f"{name}-{version}",
                targets=version_tags.strip()
            )

    return settings

def create_version_with_configurations(row, dir):
    name = row["name"]

    if "configurations" not in row:
        settings = ""
        for version_item in row["versions"]:
            version = version_item["version"]
            settings += config_setting_tpl.format(
                name=f"{name}-{version}",
                value=f"{name}-{version}",
                config=f"use_{dir}",
            )
        return settings

    settings = ""
    for version_item in row["versions"]:
        version = version_item["version"]
        default_config = row["default-configuration"]
        for config_item in row["configurations"]:
            config = config_item["name"]
            config_name = f"{name}-{config}-{version}"
            if config == default_config:
                settings += config_setting_tpl.format(
                    name=config_name,
                    value=f"{name}-{version}",
                    config=f"use_{dir}",
                )
            else:
                settings += config_setting_tpl.format(
                    name=config_name,
                    value=f"{name}-{config}-{version}",
                    config=f"use_{dir}",
                )
    return settings

# this does way too much and should probably be broken up
def create_version_configs(row):
    if "configurations" not in row:
        return ""
    
    name = row["name"]
    settings = ""
    for config_item in row["configurations"]:
        config = config_item["name"]
        versions = create_single_label(f":{name}-{config}-latest", 8)
        for version_item in row["versions"]:
            version = version_item["version"]
            versions += create_single_label(f":{name}-{config}-{version}", 8)

        settings += config_settings_group_tpl.format(
            name=f"{name}-{config}",
            targets=versions.strip()
        )
    return settings

# Used in //toolchain/<toolchain>/BUILD and //runtimes/<runtime>/BUILD files
# This creates the top-level `selects.config_setting_group` that identifies whether or not the toolchain/runtime is being used
# example outputs:
# from //toolchain/llvm/BUILD
# selects.config_setting_group(
#     name = "llvm",
#     match_any = [
#         ":llvm-latest",
#         ":llvm-19.1.7",
#     ],
# )
# from //runtime/musl/BUILD
# selects.config_setting_group(
#     name = "musl",
#     match_any = [
#         ":musl-latest",
#         ":musl-1.2.5",
#     ],
# )
def create_top_level_config_settings_group(config):
    name = config["name"]

    version_tags = create_single_label(f":{name}-latest", 8)
    for version_item in config["versions"]:
        version = version_item["version"]
        version_tags += create_single_label(f":{name}-{version}", 8)

    return config_settings_group_tpl.format(
        name=name,
        targets=version_tags.strip()
    )


# Used in //toolchain/<toolchain>/BUILD and //runtimes/<runtime>/BUILD files
# Creates the aliases that switch on the version of the toolchain/runtime
# example outputs:
# from //toolchain/llvm/BUILD:
# alias(
#     name = "c_compile",
#     actual = select({
#         ":llvm-latest": "//toolchain/llvm/19.1.7:c_compile",
#         ":llvm-19.1.7": "//toolchain/llvm/19.1.7:c_compile",
#     }),
# )
# from //runtimes/musl/BUILD:
# alias(
#     name = "include",
#     actual = select({
#         ":musl-latest": "//runtimes/musl/1.2.5:include",
#         ":musl-1.2.5": "//runtimes/musl/1.2.5:include",
#     }),
# )
def create_version_aliases(config, dir, actions):
    aliases = ""
    for action in actions:
        name = config["name"]
        latest = config["default-version"]

        configs = create_single_select_config(
            f":{name}-latest", 
            f"//{dir}/{name}/{latest}:{action}"
        )
        for version_item in config["versions"]:
            version = version_item["version"]
            configs += create_single_select_config(
                f":{name}-{version}", 
                f"//{dir}/{name}/{version}:{action}"
            )
        
        aliases += alias_tpl.format(
            action=action,
            conditions=configs.strip()
        )

    return aliases

# Used in //toolchain/<toolchain>/<version>/BUILD and //runtimes/<runtime>/<version>/BUILD files
# Creates the aliases that switch on the os and arch of the toolchain/runtime
# example outputs:
# from //toolchain/llvm/19.1.7/BUILD:
# alias(
#     name = "c_compile",
#     actual = select({
#         "//constraint:linux_x86_64": "@llvm-19.1.7-linux-x86_64//:c_compile",
#     }),
# )
# from //runtimes/musl/1.2.5/BUILD:
# alias(
#     name = "include",
#     actual = select({
#         "//constraint:linux_x86_64": "@musl-1.2.5-linux-x86_64//:include",
#     }),
# )
def create_platform_aliases(name, version_item, actions):
    version = version_item["version"]
    aliases = "package(default_visibility = [\"//:__subpackages__\"])\n\n"
    for action in actions:
        configs = ""
        for target_os_item in version_item["oses"]:
            target_os = target_os_item["name"]
            for arch_item in target_os_item["archs"]:
                arch = arch_item["name"]
                configs += create_single_select_config(
                    f"//constraint:{target_os}_{arch}", 
                    f"@{name}-{version}-{target_os}-{arch}//:{action}"
                )
        
        alias = alias_tpl.format(
            action=action,
            conditions=configs.strip()
        )

        aliases += alias
    return aliases.strip()

# This is too specific. Needs to be generalized a little bit
def create_link_args(row):
    if "configurations" not in row:
        return ""

    args = ""
    name = row["name"]
    link_args = ""
    for config_item in row["configurations"]:
        config = config_item["name"]
        link_args += f"            \":{name}-{config}\": [\n"
        for arg in config_item["link_actions"]:
            link_args += f"                \"{arg}\",\n"
        link_args += "            ],\n"
        
    args += link_arg_tpl.format(
        link_action="link_actions",
        link_args=link_args.strip()
    )

    link_args = ""
    for config_item in row["configurations"]:
        config = config_item["name"]
        link_args += f"            \":{name}-{config}\": [\n"
        for arg in config_item["link_executable_actions"]:
            link_args += f"                \"{arg}\",\n"
        link_args += "            ],\n"
        
    args += link_arg_tpl.format(
        link_action="link_executable_actions",
        link_args=link_args.strip()
    )

    return args

def generate_build_files(dir, actions):
    with open(f'repo_gen/{dir}/BUILD.tpl', 'r') as file:
        build_tpl = file.read()

    configs = get_configurations(dir)
    for config in configs:
        name = config["name"]
        os.makedirs(f"{dir}/{name}", exist_ok=True)

        with open(f"{dir}/{name}/BUILD", 'w') as file:
            file.write(build_tpl.format(name = name))
            file.write(create_link_args(config))
            file.write(create_version_aliases(config, dir, actions))
            file.write(create_top_level_config_settings_group(config))
            file.write(create_version_configs(config))
            file.write(create_latest(config, dir))
            file.write(create_latest_with_configurations(config, dir))
            file.write(create_version(config))
            # strip the last one to ensure the output only has a single newline at the end
            file.write(create_version_with_configurations(config, dir).strip())
            file.write("\n")

    for config in configs:
        name = config["name"]
        for version_item in config["versions"]:
            version = version_item["version"]
            os.makedirs(f"{dir}/{name}/{version}", exist_ok=True)
            aliases = create_platform_aliases(name, version_item, actions)

            with open(f"{dir}/{name}/{version}/BUILD", 'w') as file:
                file.write(aliases)
                file.write("\n")

if __name__ == "__main__":
    generate_module()
    generate_build_files('runtimes', ["include", "lib"])
    generate_build_files('toolchain', [
        "ar_actions",
        "assembly_actions",
        "c_compile",
        "cpp_compile_actions",
        "link_actions",
        "link_data",
        "objcopy_embed_data",
        "strip",
    ])
