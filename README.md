This is a port of [llvm-mingw](https://github.com/mstorsjo/llvm-mingw) for Windows XP.

Linker flags:
```
-lwinpthread
-lc++abi
-unwindlib=libgcc
-lgcc
-Xlinker --major-os-version=5
-Xlinker --major-subsystem-version=5
```

Work in Progress.
