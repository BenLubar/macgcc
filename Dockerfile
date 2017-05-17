FROM buildpack-deps:jessie

ENV OSX_SDK MacOSX10.10.sdk
ENV GCC_VERSION 4.8.5

RUN apt-get update \
 && apt-get install -y --no-install-recommends clang libmpc-dev libmpfr-dev libgmp-dev cmake libxml-libxml-perl libxml-libxslt-perl \
 && rm -r /var/lib/apt/lists/* \
 && git clone --depth=1 https://github.com/tpoechtrager/osxcross.git /osxcross \
 && wget -O "/osxcross/tarballs/${OSX_SDK}.tar.xz" "https://github.com/phracker/MacOSX-SDKs/releases/download/MacOSX10.11.sdk/${OSX_SDK}.tar.xz" \
 && wget -O "/osxcross/tarballs/gcc-${GCC_VERSION}.tar.bz2" "https://ftpmirror.gnu.org/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.bz2" \
 && pushd /osxcross \
 && UNATTENDED=1 ./build.sh \
 && UNATTENDED=1 GCC_VERSION="${GCC_VERSION}" ./build_gcc.sh \
 && popd \
 && apt-get purge -y --auto-remove clang libmpc-dev libmpfr-dev libgmp-dev \
 && mv /osxcross/target /osxcross-target \
 && rm -rf /osxcross \
 && mkdir /osxcross \
 && mv /osxcross-target /osxcross/target

ENV PATH /osxcross/target/bin:$PATH
