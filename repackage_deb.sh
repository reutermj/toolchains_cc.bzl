#!/bin/bash -xe

for deb_file in *.deb; do
    echo "Processing $deb_file..."
        
    mkdir -p tmp
    dpkg-deb -x "$deb_file" tmp/

    rm -rf tmp/usr/share
    rm -rf tmp/usr/src
    rm -rf tmp/lib/modules

    basename="${deb_file%.deb}"
    tar -cJf "${basename}.tar.xz" -C tmp .
    rm -rf tmp/*
done

# Remove tmp directory if empty
rmdir tmp 2>/dev/null
