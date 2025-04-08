# Notes on the implementation


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
