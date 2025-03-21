# gcc

Nightly build of gcc from source. See the [Dockerfile](https://github.com/deanturpin/gcc/blob/main/Dockerfile).

Snapshot of dumping the compiler version on the date shown. You can expose your local filesystem to the container to build local files with the latest compiler.

```bash
$ date
Wed Nov 13 22:53:21 UTC 2024

$ docker run deanturpin/gcc g++ --version
g++ (GCC) 15.0.0 20241113 (experimental)
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

## Develop

Just for info, I use `entr` to speed up the oftentimes painful Dockerfile writing experience.

```bash
 ls Dockerfile | entr -cr docker build -t gcc .
```

