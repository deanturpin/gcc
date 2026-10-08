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

A multi-stage build on `ubuntu:rolling`, the newest Ubuntu release (26.04
in October 2026, moving to 26.10 when it ships), so the tools stay current
and the base never goes out of support as the pinned `plucky` did. A new
release can rename a package; the smoke test then stops the publish. It
uses `apt-get --no-install-recommends` throughout. The builder stage installs the
build tools and GCC's dependencies (`libgmp-dev`, `libmpfr-dev`,
`libmpc-dev`, `zlib1g-dev`, and `flex`, which a git checkout needs), plus
`ca-certificates` for the https clone. The final stage holds the installed
compiler, `binutils` and `libc6-dev` (without which it can compile nothing),
`make`, `cmake` and `ninja`, and `figlet` for the banner (`neofetch`, which
Ubuntu dropped in 26.04, went with the move to `rolling`). Its
`org.opencontainers.image.revision` label is the trunk commit built.

## Nightly build

`.github/workflows/nightly.yml` runs at 02:00 UTC every night, on demand,
and when the Dockerfile or workflow changes on `main`; a pull request
touching either builds and tests but never publishes. Four jobs:

- `resolve` pins one trunk commit and date, passed to the build as
  `GCC_COMMIT`, which busts the cached clone (without it a rebuild reuses
  the old source) and becomes the image's revision label.
- `build` runs natively for amd64 (`ubuntu-24.04`) and arm64
  (`ubuntu-24.04-arm`). Each builds, smoke-tests (version, tools, label, and
  a C++26 program compiled and run), and only then pushes by digest.
- `publish` tags both digests together as `deanturpin/gcc:latest` and
  `deanturpin/gcc:YYYYMMDD`.
- `overview` calls `.github/workflows/dockerhub.yml`, which sets Docker
  Hub's short description and overview: this README with its version block
  filled in from the published image. It also runs alone, in about a minute,
  when the README changes. The README is the Docker Hub page too, so its
  links must be absolute URLs; relative ones break there.

It needs the repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`.
The token needs Read, Write, Delete: Read & Write pushes images but Docker
Hub refuses description edits without Delete.
