FROM buildpack-deps:jessie

ENV OSX_SDK MacOSX10.10.sdk
ENV GCC_VERSION 4.8.5
ENV MACOSX_DEPLOYMENT_TARGET 10.6

ENV PATH /osxcross/target/bin:$PATH
ENV OSXCROSS_GCC_NO_STATIC_RUNTIME 1

RUN apt-get update \
 && apt-get install -y --no-install-recommends clang libmpc-dev libmpfr-dev libgmp-dev cmake libxml-libxml-perl libxml-libxslt-perl python3-sphinx \
 && rm -r /var/lib/apt/lists/* \
 && git clone --depth=1 https://github.com/tpoechtrager/osxcross.git /osxcross \
 && wget -O "/osxcross/tarballs/${OSX_SDK}.tar.xz" "https://github.com/phracker/MacOSX-SDKs/releases/download/MacOSX10.11.sdk/${OSX_SDK}.tar.xz" \
 && wget -O "/osxcross/tarballs/gcc-${GCC_VERSION}.tar.bz2" "https://ftpmirror.gnu.org/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.bz2" \
 && cd /osxcross \
 && UNATTENDED=1 ./build.sh \
 && UNATTENDED=1 ./build_gcc.sh \
 && UNATTENDED=1 ./tools/osxcross-macports install zlib \
 && cd / \
 && apt-get purge -y --auto-remove clang libmpc-dev libmpfr-dev libgmp-dev \
 && mv /osxcross/target /osxcross-target \
 && rm -rf /osxcross \
 && mkdir /osxcross \
 && mv /osxcross-target /osxcross/target \
 && apt-get install -y --no-install-recommends ccache

ENV PATH /usr/lib/ccache:$PATH

RUN ln -s /osxcross/target/macports/pkgs/opt/local/lib/libz.dylib /usr/lib/libz.dylib \
 && ln -s /bin/true /osxcross/target/bin/install_name_tool
