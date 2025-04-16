# Notes on the implementation

## Useful links

### Alpine Packages
downloading: https://dl-cdn.alpinelinux.org/alpine/
searching: https://pkgs.alpinelinux.org/packages
Build scripts: https://gitlab.alpinelinux.org/alpine/aports

## TODO

`platform_data` might allow for changing the toolchain for different targets. need to investigate

https://github.com/bazelbuild/rules_platform/blob/main/platform_data/defs.bzl
## linux-libc-dev
TODO currently having to manually remove the link args because the template always includes them


## glibc

glibc headers depend on linux headers. musl copy pastes the constants into the header

```
external/toolchains_cc++_repo_rules+glibc-2.31-linux-x86_64/include/bits/errno.h:26:11: fatal error: 'linux/errno.h' file not found
   26 | # include <linux/errno.h>
```

## libstdc++

the .so in the ubuntu package is a symlink and clang will be *so* helpful and just link the static lib when it cant find the target

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


## Include path ordering

Looks like it's c++, then toolchain, then c headers...

`g++ -v` gives

```
#include <...> search starts here:
 /usr/include/c++/12
 /usr/include/x86_64-linux-gnu/c++/12
 /usr/include/c++/12/backward
 /usr/lib/gcc/x86_64-linux-gnu/12/include
 /usr/local/include
 /usr/include/x86_64-linux-gnu
 /usr/include
```

`clang++ -v` gives

```
#include <...> search starts here:
 /usr/bin/../lib/gcc/x86_64-linux-gnu/12/../../../../include/c++/12
 /usr/bin/../lib/gcc/x86_64-linux-gnu/12/../../../../include/x86_64-linux-gnu/c++/12
 /usr/bin/../lib/gcc/x86_64-linux-gnu/12/../../../../include/c++/12/backward
 /usr/lib/llvm-14/lib/clang/14.0.6/include
 /usr/local/include
 /usr/include/x86_64-linux-gnu
 /usr/include
```

### glibc include path ordering errors

glibc really cares about the toolchain headers being above the glibc headers. 
otherwise, you'll get errors complaining about not finding `size_t`.
note the incorrect include path ordering:

```
#include <...> search starts here:
 external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include
 external/toolchains_cc++_repo_rules+llvm-19.1.7-linux-x86_64/include
End of search list.
In file included from main.c:1:
In file included from external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include/stdio.h:41:
external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include/bits/libio.h:306:3: error: unknown type name 'size_t'
  306 |   size_t __pad5;
      |   ^
external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include/bits/libio.h:309:67: error: use of undeclared identifier 'size_t'; did you mean 'sizeof'?
  309 |   char _unused2[15 * sizeof (int) - 4 * sizeof (void *) - sizeof (size_t)];
      |                                                                   ^
external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include/bits/libio.h:309:66: error: reference to overloaded function could not be resolved; did you mean to call it?
  309 |   char _unused2[15 * sizeof (int) - 4 * sizeof (void *) - sizeof (size_t)];
      |                                                                  ^~~~~~~~
external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include/bits/libio.h:337:62: error: unknown type name 'size_t'
  337 | typedef __ssize_t __io_read_fn (void *__cookie, char *__buf, size_t __nbytes);
      |                                                              ^
external/toolchains_cc++_repo_rules+glibc-2.27-linux-x86_64/include/bits/libio.h:346:6: error: unknown type name 'size_t'
  346 |                                  size_t __n);
      |                                  ^
```
