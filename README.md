# gcc

Nightly build of gcc from source. See the [Dockerfile](https://github.com/deanturpin/gcc/blob/main/Dockerfile).

Snapshot of dumping the compiler version on the date shown.

```bash
$ date
Wed Nov 13 22:53:21 UTC 2024

$ docker run deanturpin/gcc g++ --version
g++ (GCC) 15.0.0 20241113 (experimental)
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```