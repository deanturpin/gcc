# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This repository builds a Docker image containing the latest GCC compiler from
source (nightly build from gcc.gnu.org/git). The image is published as
`deanturpin/gcc` and provides bleeding-edge GCC experimental builds.

## Docker Commands

Build the image:

```bash
docker build -t gcc .
```

Run the container to see version info:

```bash
docker run deanturpin/gcc
```

Use the compiler on local files (mount your filesystem):

```bash
docker run -v $(pwd):/workspace -w /workspace deanturpin/gcc g++ --version
docker run -v $(pwd):/workspace -w /workspace deanturpin/gcc g++ yourfile.cpp -o yourfile
```

## Development Workflow

The Dockerfile uses `entr` for rapid iteration during development:

```bash
ls Dockerfile | entr -cr docker build -t gcc .
```

## Build Configuration

The GCC build is configured with:

- Language support: C++ only (`--enable-languages=c++`)
- Single architecture: `--disable-multilib`
- System zlib: `--with-system-zlib`
- No bootstrap: `--disable-bootstrap` (faster single-stage build)
- Parallel build using all available cores: `-j $(nproc)`

## Base Image

A multi-stage build on `ubuntu:noble` (24.04 LTS, supported to 2029): the
builder stage installs the build tools and GCC's dependencies (`libgmp3-dev`,
`libmpfr-dev`, `libmpc-dev`, `libz-dev`, `flex`), and the final stage holds
only the installed compiler, its runtime libraries, and `figlet` and
`neofetch` for the version banner.

## Nightly build

`.github/workflows/nightly.yml` builds and pushes `deanturpin/gcc:latest` and
a dated tag (`deanturpin/gcc:YYYYMMDD`) at 02:00 UTC every night, on demand,
and when the Dockerfile changes. It needs the repository secrets
`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` (a Docker Hub access token with
write access). It passes the trunk commit as `GCC_COMMIT`, which busts the
cached clone; without it a rebuild reuses the old source.
