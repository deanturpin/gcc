# Build stage
FROM ubuntu:noble AS builder

RUN echo Using $(nproc) cores

RUN apt update && \
    apt install --yes git make cmake build-essential \
        libgmp3-dev libmpfr-dev libmpc-dev libz-dev flex

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
FROM ubuntu:noble

# The compiler alone can't build anything: it needs the assembler and linker
# (binutils) and the C library's headers and start files (libc6-dev)
RUN apt update && \
    apt install --yes binutils libc6-dev figlet neofetch \
        libgmp10 libmpfr6 libmpc3 zlib1g && \
    rm -rf /var/lib/apt/lists/*

# Copy only the installed GCC binaries from builder
COPY --from=builder /gcc-install/usr/local /usr/local

# Programs it builds need its own libstdc++, newer than the system's, so put
# its libraries ahead of the system's in the loader's search
RUN echo /usr/local/lib64 > /etc/ld.so.conf.d/00-gcc.conf && ldconfig

# Dump some version info
WORKDIR /root
CMD ["sh", "-c", "figlet deanturpin/gcc && neofetch --stdout && g++ --version"]
