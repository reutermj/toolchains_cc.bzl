import csv

def generate_module():
    # open the templates
    with open('MODULE.tpl.bazel', 'r') as file:
        module_tpl = file.read()
    with open('http_archive.tpl.bazel', 'r') as file:
        http_archive_tpl = file.read()
    with open('toolchains.csv', 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        toolchains = [row for row in csvreader if any(row)]
    
    # create the http_archive format replacements for the toolchain archives
    archives = {}
    for toolchain in toolchains:
        name = toolchain[0]
        version = toolchain[1]
        os = toolchain[2]
        arch = toolchain[3]
        sha = toolchain[4]
        key = f"{name}_{os}_{arch}"

        if key not in archives:
            archives[key] = ""
        http_archive = http_archive_tpl.format(
            type=name,
            version=version,
            os=os,
            arch=arch,
            sha=sha
        )
        archives[key] += http_archive

    # write out the module file
    module = module_tpl.format(**archives)
    with open('MODULE.bazel', 'w') as file:
        file.write(module)
        
    
if __name__ == "__main__":
    generate_module()