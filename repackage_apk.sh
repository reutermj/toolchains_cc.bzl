#!/bin/bash -xe

for apk_file in *.apk; do
    echo "Processing $apk_file..."
        
    mkdir -p tmp
    tar -xf "$apk_file" -C tmp/

    rm -rf tmp/usr/share
    rm -rf tmp/usr/src
    rm -rf tmp/usr/bin
    rm -rf tmp/usr/libexec
    rm -rf tmp/lib/modules

    basename="${apk_file%.apk}"
    tar -cJf "${basename}.tar.xz" -C tmp .
    # rm -rf tmp/*
done

# Remove tmp directory if empty
# rmdir tmp 2>/dev/null
