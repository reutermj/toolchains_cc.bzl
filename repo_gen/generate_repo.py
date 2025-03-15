import csv
import os

# ===============
# || Templates ||
# ===============
http_archive_tpl = """
http_archive(
    name = "{type}-{version}-{target_os}-{arch}",
    url = "https://github.com/reutermj/toolchains_cc/releases/download/binaries/{type}-{version}-{target_os}-{arch}.tar.xz",
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
    }}),
)
"""

config_settings_group_tpl = """
selects.config_setting_group(
    name = "{name}",
    match_any = [
        ":{name}-latest",
        {versions}
    ],
)
""".lstrip()

# =======================
# || Utility Functions ||
# =======================
def get_csv_rows(dir):
    with open(f'repo_gen/{dir}.csv', 'r') as file:
        reader = csv.reader(file)
        runtimes = [row for row in reader if any(row)]
    return runtimes

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
        name = row[0]
        version = row[1]
        target_os = row[2]
        arch = row[3]

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

def create_version_configs(version_lookup, config):
    name_to_configs = {}
    for name, lookup in version_lookup.items():
        versions = lookup["versions"]
        settings = ""
        for version in versions:
            settings += config_setting_tpl.format(
                value=f"{name}-{version}",
                config=config,
            )
        name_to_configs[name] = settings.strip()
    return name_to_configs

def create_version_aliases(versions_lookup, dir, actions):
    name_to_aliases = {}
    for action in actions:
        for name, versions_latest in versions_lookup.items():
            versions = versions_latest["versions"]
            latest = versions_latest["latest"]
            conditions = f"        \":{name}-latest\": \"//{dir}/{name}/{latest}:{action}\",\n"
            for version in versions:
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

def create_config_settings_group(version_lookup):
    name_to_group = {}
    for name, lookup in version_lookup.items():
        versions = lookup["versions"]

        version_tags = ""
        for version in versions:
            version_tags += f"        \":{name}-{version}\",\n"

        name_to_group[name] = config_settings_group_tpl.format(
            name=name,
            versions=version_tags.strip()
        )
    return name_to_group

def create_platform_aliases(name, version, platforms, actions):
    aliases = "package(default_visibility = [\"//:__subpackages__\"])\n"
    for action in actions:
        conditions = ""
        for platform in platforms:
            target_os = platform["os"]
            arch = platform["arch"]
            conditions += f"        \"//constraint:{target_os}_{arch}\": \"@{name}-{version}-{target_os}-{arch}//:{action}\",\n"
        
        alias = alias_tpl.format(
            action=action,
            conditions=conditions.strip()
        )

        aliases += alias
    return aliases.strip()

def create_module_archives(rows, archives):
    for row in rows:
        name = row[0]
        version = row[1]
        target_os = row[2]
        arch = row[3]
        sha = row[4]
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

# =========================
# || Generator Functions ||
# =========================
def generate_module():
    with open('repo_gen/MODULE.bazel.tpl', 'r') as file:
        module_tpl = file.read()
    
    archives = {}
    create_module_archives(get_csv_rows('toolchain'), archives)
    create_module_archives(get_csv_rows('runtimes'), archives)

    module = module_tpl.format(**archives)
    with open('MODULE.bazel', 'w') as file:
        file.write(module)

def generate_build_files(dir, actions):
    with open(f'repo_gen/{dir}/BUILD.tpl', 'r') as file:
        build_tpl = file.read()

    versions_lookup = create_version_lookup(get_csv_rows(dir))
    name_to_configs = create_version_configs(versions_lookup, f"use_{dir}")
    name_to_aliases = create_version_aliases(versions_lookup, dir, actions)
    name_to_group = create_config_settings_group(versions_lookup)

    for name, _ in versions_lookup.items():
        os.makedirs(f"{dir}/{name}", exist_ok=True)
        build = build_tpl.format(
            name = name,
            version_aliases=name_to_aliases[name],
            config_setting_group=name_to_group[name],
            version_configs=name_to_configs[name]
        )

        with open(f"{dir}/{name}/BUILD", 'w') as file:
            file.write(build)

    for name, lookup in versions_lookup.items():
        for version, platforms in lookup["version_to_platforms"].items():
            os.makedirs(f"{dir}/{name}/{version}", exist_ok=True)
            aliases = create_platform_aliases(name, version, platforms, actions)

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
