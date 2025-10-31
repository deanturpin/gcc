# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository builds a Docker image containing the latest GCC compiler from source (nightly build from gcc.gnu.org/git). The image is published as `deanturpin/gcc` and provides bleeding-edge GCC experimental builds.

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

Uses the official `gcc` Docker image as the base, which already includes essential build tools. Additional packages installed:
- `figlet`, `neofetch` (for version display)
- `libgmp3-dev`, `libmpfr-dev`, `libmpc-dev` (GCC build dependencies)
- `libz-dev`, `flex` (build requirements)
