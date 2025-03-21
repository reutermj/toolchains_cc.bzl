import os
import json

def get_configurations(dir):
    with open(f'repo_gen/{dir}.json', 'r') as file:
        rows = json.load(file)
    
    return rows

def is_newer(version, latest):
    version = version.split('.')
    latest = latest.split('.')
    for v, l in zip(version, latest):
        if int(v) > int(l):
            return True
        elif int(v) < int(l):
            return False
    return False

def create_version_lookup(rows):
    versions_lookup = {}
    for row in rows:
        name = row["name"]
        version = row["version"]
        target_os = row["os"]
        arch = row["arch"]

        if name not in versions_lookup:
            versions_lookup[name] = {
                "versions": set(),
                "latest": "0.0.0",
                "version_to_platforms": {}
            }
        if version not in versions_lookup[name]["version_to_platforms"]:
            versions_lookup[name]["version_to_platforms"][version] = []
        
        versions_lookup[name]["versions"].add(version)
        versions_lookup[name]["version_to_platforms"][version].append({
            "os": target_os,
            "arch": arch
        })

        if is_newer(version, versions_lookup[name]["latest"]):
            versions_lookup[name]["latest"] = version
    
    return versions_lookup

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
        {versions}
    ],
)
""".lstrip()

def create_version_configs(rows, dir):
    name_to_configs = {}
    for row in rows:
        name = row["name"]
        settings = ""
        if "configurations" in row:
            configs = []
            for config, info in row["configurations"].items():
                config_name = f"{name}-{config}-latest"
                configs.append(config_name)
                if info["is-default"]:
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

            version_tags = ""
            for config in configs:
                version_tags += f"        \":{config}\",\n"
            
            settings += config_settings_group_tpl.format(
                name=f"{name}-latest",
                versions=version_tags.strip()
            )
        else:
            settings += config_setting_tpl.format(
                name=f"{name}-latest",
                value=f"{name}",
                config=f"use_{dir}",
            )

        for version, _ in row["versions"].items():
            if "configurations" in row:
                configs = []
                for config, info in row["configurations"].items():
                    config_name = f"{name}-{config}-{version}"
                    configs.append(config_name)
                    if info["is-default"]:
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
                
                version_tags = ""
                for config in configs:
                    version_tags += f"        \":{config}\",\n"
                
                settings += config_settings_group_tpl.format(
                    name=f"{name}-{version}",
                    versions=version_tags.strip()
                )
            else:
                settings += config_setting_tpl.format(
                    name=f"{name}-{version}",
                    value=f"{name}-{version}",
                    config=f"use_{dir}",
                )
        if "configurations" in row:
            for config, info in row["configurations"].items():
                versions = f"        \":{name}-{config}-latest\",\n"
                for version, _ in row["versions"].items():
                    versions += f"        \":{name}-{config}-{version}\",\n"

                settings += config_settings_group_tpl.format(
                    name=f"{name}-{config}",
                    versions=versions.strip()
                )

        name_to_configs[name] = settings.strip()
    return name_to_configs

def create_config_settings_group(rows):
    name_to_group = {}
    for row in rows:
        name = row["name"]
        version_tags = f"        \":{name}-latest\",\n"
        for version, _ in row["versions"].items():
            version_tags += f"        \":{name}-{version}\",\n"

        name_to_group[name] = config_settings_group_tpl.format(
            name=name,
            versions=version_tags.strip()
        )
    return name_to_group

alias_tpl = """
alias(
    name = "{action}",
    actual = select({{
        {conditions}
    }}),
)
"""

def create_version_aliases(rows, dir, actions):
    name_to_aliases = {}
    for action in actions:
        for row in rows:
            name = row["name"]
            latest = row["default-version"]
            conditions = f"        \":{name}-latest\": \"//{dir}/{name}/{latest}:{action}\",\n"
            for version, _ in row["versions"].items():
                conditions += f"        \":{name}-{version}\": \"//{dir}/{name}/{version}:{action}\",\n"
            
            alias = alias_tpl.format(
                action=action,
                conditions=conditions.strip()
            )

            if name in name_to_aliases:
                name_to_aliases[name] += alias
            else:
                name_to_aliases[name] = alias

    return name_to_aliases

def create_platform_aliases(name, version, os_to_arch, actions):
    aliases = "package(default_visibility = [\"//:__subpackages__\"])\n"
    for action in actions:
        conditions = ""
        for target_os, arch_to_info in os_to_arch.items():
            for arch, _ in arch_to_info.items():
                conditions += f"        \"//constraint:{target_os}_{arch}\": \"@{name}-{version}-{target_os}-{arch}//:{action}\",\n"
        
        alias = alias_tpl.format(
            action=action,
            conditions=conditions.strip()
        )

        aliases += alias
    return aliases.strip()


http_archive_tpl = """
http_archive(
    name = "{type}-{version}-{target_os}-{arch}",
    url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/{artifact_name}",
    sha256 = "{sha}",
)
""".lstrip()

def create_module_archives(rows, archives):
    for row in rows:
        for version, os_to_arch in row["versions"].items():
            for target_os, archs in os_to_arch.items():
                for arch, info in archs.items():
                    key = "{name}_{target_os}_{arch}".format(
                        name=row["name"], 
                        target_os=target_os, 
                        arch=arch
                    )

                    if key not in archives:
                        archives[key] = ""

                    http_archive = http_archive_tpl.format(
                        type=row["name"],
                        version=version,
                        target_os=target_os,
                        arch=arch,
                        sha=info["sha256"],
                        artifact_name=info["artifact-name"]
                    )
                    archives[key] += http_archive

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
"""

def create_link_args(rows):
    name_to_link_args = {}
    for row in rows:
        name = row["name"]
        link_args = ""
        for config, info in row["configurations"].items():
            link_args += f"            \":{name}-{config}\": [\n"
            for arg in info["link_actions"]:
                link_args += f"                \"{arg}\",\n"
            link_args += "            ],\n"
            
        name_to_link_args[name] = link_arg_tpl.format(
            link_action="link_actions",
            link_args=link_args.strip()
        )
    
    for row in rows:
        name = row["name"]
        link_args = ""
        for config, info in row["configurations"].items():
            link_args += f"            \":{name}-{config}\": [\n"
            for arg in info["link_executable_actions"]:
                link_args += f"                \"{arg}\",\n"
            link_args += "            ],\n"
            
        name_to_link_args[name] += link_arg_tpl.format(
            link_action="link_executable_actions",
            link_args=link_args.strip()
        )

    return name_to_link_args

def generate_module():
    with open('repo_gen/MODULE.bazel.tpl', 'r') as file:
        module_tpl = file.read()
    
    archives = {}
    create_module_archives(get_configurations('toolchain'), archives)
    create_module_archives(get_configurations('runtimes'), archives)

    module = module_tpl.format(**archives)
    with open('MODULE.bazel', 'w') as file:
        file.write(module)

def generate_build_files(dir, actions):
    with open(f'repo_gen/{dir}/BUILD.tpl', 'r') as file:
        build_tpl = file.read()

    configurations = get_configurations(dir)
    name_to_configs = create_version_configs(configurations, dir)
    name_to_aliases = create_version_aliases(configurations, dir, actions)
    name_to_group = create_config_settings_group(configurations)
    name_to_link_args = create_link_args(configurations)

    for row in configurations:
        name = row["name"]
        os.makedirs(f"{dir}/{name}", exist_ok=True)
        build = build_tpl.format(
            name = name,
            version_aliases=name_to_aliases[name],
            config_setting_group=name_to_group[name],
            version_configs=name_to_configs[name],
            link_args=name_to_link_args[name]
        )

        with open(f"{dir}/{name}/BUILD", 'w') as file:
            file.write(build)

    for row in configurations:
        for version, os_to_arch in row["versions"].items():
            os.makedirs(f"{dir}/{name}/{version}", exist_ok=True)
            aliases = create_platform_aliases(name, version, os_to_arch, actions)

            with open(f"{dir}/{name}/{version}/BUILD", 'w') as file:
                file.write(aliases)
                file.write("\n")
                

            

if __name__ == "__main__":
    generate_module()
    generate_build_files('runtimes', ["include", "lib"])
    # generate_build_files('toolchain', [
    #     "ar_actions",
    #     "assembly_actions",
    #     "c_compile",
    #     "cpp_compile_actions",
    #     "link_actions",
    #     "link_data",
    #     "objcopy_embed_data",
    #     "strip",
    # ])
