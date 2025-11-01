# Build stage
FROM ubuntu:plucky AS builder

RUN echo Using $(nproc) cores

RUN apt update && \
    apt install --yes git make cmake build-essential \
        libgmp3-dev libmpfr-dev libmpc-dev libz-dev flex

# Shallow clone the source
RUN git clone --depth=1 git://gcc.gnu.org/git/gcc.git

# Configure the compiler
RUN mkdir /build
WORKDIR /build
RUN ../gcc/configure --enable-languages=c++ --disable-multilib --with-system-zlib --disable-bootstrap

# Build and install to a temporary location
RUN make --silent -j $(nproc)
RUN make -j $(nproc) install DESTDIR=/gcc-install

# Final stage - minimal runtime image
FROM ubuntu:plucky

RUN apt update && \
    apt install --yes figlet neofetch libgmp10 libmpfr6 libmpc3 zlib1g && \
    rm -rf /var/lib/apt/lists/*

# Copy only the installed GCC binaries from builder
COPY --from=builder /gcc-install/usr/local /usr/local

# Dump some version info
WORKDIR /root
CMD figlet deanturpin/gcc && \
    neofetch --stdout && \
    g++ --version
