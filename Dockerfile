FROM ubuntu:plucky

RUN echo Using $(nproc) cores

RUN apt update && \
    apt install --yes figlet neofetch \
        git make cmake build-essential \
        libgmp3-dev libmpfr-dev libmpc-dev libz-dev flex

# Shallow clone the source
RUN git clone --depth=1 git://gcc.gnu.org/git/gcc.git

# Configure the compiler
RUN mkdir build
WORKDIR build
RUN ../gcc/configure --enable-languages=c++ --disable-multilib --with-system-zlib --disable-bootstrap

# Build and install
RUN make --silent -j $(nproc)
RUN make -j $(nproc) install

# Dump some version info
WORKDIR /root
CMD figlet deanturpin/gcc && \
    neofetch --stdout && \
    g++ --version && \
    dpkg -l $PACKAGES
