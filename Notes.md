# Notes on the implementation

## Useful links

### Alpine Packages
downloading: https://dl-cdn.alpinelinux.org/alpine/
searching: https://pkgs.alpinelinux.org/packages
Build scripts: https://gitlab.alpinelinux.org/alpine/aports

## TODO

`platform_data` might allow for changing the toolchain for different targets. need to investigate

https://github.com/bazelbuild/rules_platform/blob/main/platform_data/defs.bzl

## libc++

### Incompatibility between libc++ from the llvm builds and musl

```
error: "<locale.h> is not supported since libc++ has been configured without support for localization."
```

You need to get a version of libc++ specifically compiled for musl. When configuring the libc++ cmake:

```
-DLIBCXX_HAS_MUSL_LIBC=ON
```

reference: https://github.com/dslm4515/CMLFS/issues/69

### TODO

figure out why I need to link lzma? I dont think I actually want this to be part of the general musl build flow

## Toolchains

toolchains contain specific definitions for things like `stddef.h`. glibc relies on these to be there but it appears that musl doesnt?

either way, need to look into include path ordering to make sure im getting it in the right order.
