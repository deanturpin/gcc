# Build stage. rolling is always the newest Ubuntu release, so the tools
# stay current and the base never falls out of support
FROM ubuntu:rolling AS builder

# Building from a git checkout, unlike a release tarball, needs flex.
# ca-certificates is named because --no-install-recommends drops it, and the
# clone is over https
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        build-essential ca-certificates git flex \
        libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev

# Shallow clone the tip of trunk. GCC_COMMIT (the current trunk commit) is
# only there to invalidate Docker's cached clone, so a rebuild fetches new
# source rather than reusing the last one
ARG GCC_COMMIT
RUN echo Building trunk at ${GCC_COMMIT} && \
    git clone --depth=1 https://gcc.gnu.org/git/gcc.git

# Configure the compiler
RUN mkdir /build
WORKDIR /build
RUN ../gcc/configure --enable-languages=c++ --disable-multilib --with-system-zlib --disable-bootstrap

# Build and install to a temporary location
RUN make --silent -j $(nproc)
RUN make -j $(nproc) install DESTDIR=/gcc-install

# Final stage - minimal runtime image
FROM ubuntu:rolling

# The trunk commit this compiler was built from, so `docker inspect` can
# trace a regression to its source
ARG GCC_COMMIT
LABEL org.opencontainers.image.revision=${GCC_COMMIT} \
      org.opencontainers.image.source=https://gcc.gnu.org/git/gcc.git \
      org.opencontainers.image.url=https://github.com/deanturpin/gcc \
      org.opencontainers.image.description="GCC trunk built from source every night, C++ only"

# The compiler alone can't build anything: it needs the assembler and linker
# (binutils) and the C library's headers and start files (libc6-dev). make,
# cmake and ninja are there so it builds whole projects, not just files
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        binutils libc6-dev make cmake ninja-build figlet neofetch \
        libgmp10 libmpfr6 libmpc3 zlib1g && \
    rm -rf /var/lib/apt/lists/*

# Copy only the installed GCC binaries from builder
COPY --from=builder /gcc-install/usr/local /usr/local

# Programs it builds need its own libstdc++, newer than the system's, so put
# its libraries ahead of the system's in the loader's search
RUN printf '/usr/local/lib64\n/usr/local/lib\n' > /etc/ld.so.conf.d/00-gcc.conf && ldconfig

# Dump some version info
WORKDIR /root
CMD ["sh", "-c", "figlet deanturpin/gcc && neofetch --stdout && g++ --version"]
