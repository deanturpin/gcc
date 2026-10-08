# gcc

Nightly build of gcc from source, published to Docker Hub as
`deanturpin/gcc:latest` and `deanturpin/gcc:YYYYMMDD` by a
[GitHub Actions workflow](.github/workflows/nightly.yml). See the
[Dockerfile](Dockerfile).

Each build is native for amd64 and arm64 (Apple silicon included), under the
same tags, so Docker pulls the right one. Alongside the compiler the image
has `make`, `cmake` and `ninja`, so it builds whole projects. The trunk
commit it was built from is in its labels:

```bash
docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.revision" }}' deanturpin/gcc
```

Tags are `latest` and the build date, so `deanturpin/gcc:20261008` is GCC
trunk as it stood that day. On Docker Hub the block below shows the latest
build's real output, written by each night's run.

<!-- version -->
```bash
docker run --rm deanturpin/gcc g++ --version
```
<!-- /version -->

Mount your working directory to build local files with the latest compiler:

```bash
docker run --rm -v "$PWD:/w" -w /w deanturpin/gcc g++ -std=c++26 hello.cxx -o hello
```

## Develop

Just for info, I use `entr` to speed up the oftentimes painful Dockerfile
writing experience.

```bash
 ls Dockerfile | entr -cr docker build -t gcc .
```
