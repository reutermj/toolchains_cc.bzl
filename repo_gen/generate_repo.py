import csv
import os

def get_toolchains():
    with open('repo_gen/toolchains.csv', 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        toolchains = [row for row in csvreader if any(row)]
    return toolchains

actions = [
    "ar_actions",
    "assembly_actions",
    "c_compile",
    "cpp_compile_actions",
    "link_actions",
    "link_data",
    "objcopy_embed_data",
    "strip",
]

visibility = "package(default_visibility = [\"//:__subpackages__\"])\n"

# ===============
# || Templates ||
# ===============
http_archive_tpl = """
http_archive(
    name = "{type}-{version}-{target_os}-{arch}",
    url = "https://github.com/reutermj/toolchains_cc/releases/download/{type}-{version}/{type}-{version}-{target_os}-{arch}.tar.xz",
    sha256 = "{sha}",
)
""".lstrip()

config_setting_tpl = """
config_setting(
    name = "{value}",
    flag_values = {{
        "//:{config}": "{value}",
    }},
)
""".lstrip()

alias_tpl = """
alias(
    name = "{action}",
    actual = select({{
        {conditions}
    }})
)
"""

# ==================
# || MODULE.bazel ||
# ==================
def generate_module():
    # open the templates
    with open('repo_gen/MODULE.bazel.tpl', 'r') as file:
        module_tpl = file.read()

    toolchains = get_toolchains()
    
    # create the http_archive format replacements for the toolchain archives
    archives = {}
    for toolchain in toolchains:
        name = toolchain[0]
        version = toolchain[1]
        target_os = toolchain[2]
        arch = toolchain[3]
        sha = toolchain[4]
        key = f"{name}_{target_os}_{arch}"

        if key not in archives:
            archives[key] = ""
        http_archive = http_archive_tpl.format(
            type=name,
            version=version,
            target_os=target_os,
            arch=arch,
            sha=sha
        )
        archives[key] += http_archive

    # write out the module file
    module = module_tpl.format(**archives)
    with open('MODULE.bazel', 'w') as file:
        file.write(module)

# ========================
# || //toolchains/BUILD ||
# ========================
def generate_root_build():
    with open('repo_gen/BUILD.tpl', 'r') as file:
        build_tpl = file.read()
    toolchains = get_toolchains()

    toolchain_to_versions = {}
    versions = ""
    for toolchain in toolchains:
        name = toolchain[0]
        version = toolchain[1]

        if name not in toolchain_to_versions:
            toolchain_to_versions[name] = set()
        toolchain_to_versions[name].add(version)

        config_setting = config_setting_tpl.format(
            value=f"{name}-{version}",
            config="use_toolchain",
        )

        versions += config_setting

    formatting = {"version_configs": versions}
    for name, versions in toolchain_to_versions.items():
        version_tags = ""
        for version in versions:
            version_tags += f"        \":{name}-{version}\",\n"
        formatting[f"{name}_versions"] = version_tags.strip()

    build = build_tpl.format(**formatting)
    with open('toolchains/BUILD', 'w') as file:
        file.write(build)

# ====================================
# || //toolchains/<toolchain>/BUILD ||
# ====================================
def is_newer(version, latest):
    version = version.split('.')
    latest = latest.split('.')
    for v, l in zip(version, latest):
        if int(v) > int(l):
            return True
        elif int(v) < int(l):
            return False
    return False

def generate_tool_build():
    toolchains = get_toolchains()

    # aggregate all valid versions for a given toolchain
    versions_lookup = {}
    for toolchain in toolchains:
        name = toolchain[0]
        version = toolchain[1]

        if name not in versions_lookup:
            versions_lookup[name] = {
                "versions": set(),
                "latest": "0.0.0"
            }

        versions_lookup[name]["versions"].add(version)
        if is_newer(version, versions_lookup[name]["latest"]):
            versions_lookup[name]["latest"] = version
    
    # write out the aliases that picks out the version specified by the --@toolchains_cc//:version config
    aliases = visibility
    for action in actions:
        for name, versions_latest in versions_lookup.items():
            versions = versions_latest["versions"]
            latest = versions_latest["latest"]
            os.makedirs(f"toolchains/{name}", exist_ok=True)
            conditions = f"        \"//toolchains:{name}-latest\": \"//toolchains/{name}/{latest}:{action}\",\n"
            for version in versions:
                conditions += f"        \"//toolchains:{name}-{version}\": \"//toolchains/{name}/{version}:{action}\",\n"
            
            alias = alias_tpl.format(
                action=action,
                conditions=conditions.strip()
            )

            aliases += alias

    with open(f"toolchains/{name}/BUILD", 'w') as file:
        file.write(aliases)

# ==============================================
# || //toolchains/<toolchain>/<version>/BUILD ||
# ==============================================
def generate_tool_version_build():
    toolchains = get_toolchains()

    toolchain_to_version_to_os_arch = {}
    for toolchain in toolchains:
        name = toolchain[0]
        version = toolchain[1]
        target_os = toolchain[2]
        arch = toolchain[3]

        if name not in toolchain_to_version_to_os_arch:
            toolchain_to_version_to_os_arch[name] = {}

        version_to_os_arch = toolchain_to_version_to_os_arch[name]
        if version not in version_to_os_arch:
            version_to_os_arch[version] = []
        
        version_to_os_arch[version].append((target_os, arch))
    
    for name, version_to_os_arch in toolchain_to_version_to_os_arch.items():
        for version, targets in version_to_os_arch.items():
            os.makedirs(f"toolchains/{name}/{version}", exist_ok=True)

            aliases = visibility
            for action in actions:
                conditions = ""
                for (target_os, arch) in targets:
                    conditions += f"        \"//constraint:{target_os}_{arch}\": \"@{name}-{version}-{target_os}-{arch}//:{action}\",\n"
                
                alias = alias_tpl.format(
                    action=action,
                    conditions=conditions.strip()
                )

                aliases += alias

            with open(f"toolchains/{name}/{version}/BUILD", 'w') as file:
                file.write(aliases.strip())
                file.write("\n")


if __name__ == "__main__":
    generate_module()
    generate_root_build()
    generate_tool_build()
    generate_tool_version_build()