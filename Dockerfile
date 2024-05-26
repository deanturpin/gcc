FROM deanturpin/dev AS build

# Shallow clone the source
RUN git clone --depth=1 git://gcc.gnu.org/git/gcc.git

# Configure the compiler
RUN apt install --yes libgmp3-dev libmpfr-dev libmpc-dev libz-dev flex file
RUN mkdir build
WORKDIR build
RUN ../gcc/configure --enable-languages=c++ --disable-multilib --with-system-zlib --disable-bootstrap

# Build and install
RUN make --silent -j $(nproc)
RUN make -j $(nproc) install

# Start next stage and copy the artifacts
FROM deanturpin/dev

# Copy build artifacts from first stage
COPY --from=build /usr/local /usr/local

# Dump some version info
WORKDIR /root
CMD figlet -f small -w 60 docker run deanturpin/gcc && \
	neofetch --stdout && \
	g++ --version && \
	xz --version && \
	dpkg -l $PACKAGES
