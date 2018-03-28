FROM buildpack-deps:bionic

ENV OSXCROSS_GIT_COMMIT=1a1733a773fe26e7b6c93b16fbf9341f22fac831 \
    OSX_SDK=MacOSX10.10.sdk \
    GCC_VERSION=4.8.5 \
    CMAKE_VERSION_MAJOR=3.11 \
    CMAKE_VERSION=3.11.0 \
    MACOSX_DEPLOYMENT_TARGET=10.6 \
    PATH=/osxcross/target/bin:/opt/cmake/bin:$PATH \
    OSXCROSS_GCC_NO_STATIC_RUNTIME=1

ADD osxcross-patches.diff /osxcross/osxcross-patches.diff

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        clang \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
        libxml-libxml-perl \
        libxml-libxslt-perl \
        python3-sphinx \
 && mkdir -p "/osxcross/tarballs" "/opt/cmake" \
 && cd /osxcross/tarballs \
 && wget -O "osxcross.tar.gz" "https://github.com/tpoechtrager/osxcross/archive/${OSXCROSS_GIT_COMMIT}.tar.gz" \
 && wget -O "${OSX_SDK}.tar.xz" "https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/${OSX_SDK}.tar.xz" \
 && wget -O "gcc-${GCC_VERSION}.tar.gz" "https://ftpmirror.gnu.org/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz" \
 && wget -O "cmake-${CMAKE_VERSION}.tar.gz" "https://cmake.org/files/v${CMAKE_VERSION_MAJOR}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz" \
 && (echo "c6cead036022edb7013a6adebf5c6832e06d5281b72515b10890bf91b8fe9ada  osxcross.tar.gz"; \
     echo "4a08de46b8e96f6db7ad3202054e28d7b3d60a3d38cd56e61f08fb4863c488ce  MacOSX10.10.sdk.tar.xz"; \
     echo "1dbc5cd94c9947fe5dffd298e569de7f44c3cedbd428fceea59490d336d8295a  gcc-4.8.5.tar.gz"; \
     echo "5babc7953b50715028a05823d18fd91b62805b10aa7811e5fd02b27224d60f10  cmake-3.11.0.tar.gz") | sha256sum -c \
 \
 && tar xzCf "/osxcross" "/osxcross/tarballs/osxcross.tar.gz" --strip-components=1 \
 && tar xzCf "/opt/cmake" "/osxcross/tarballs/cmake-${CMAKE_VERSION}.tar.gz" --strip-components=1 \
 \
 && cd /osxcross \
 && patch -p1 < osxcross-patches.diff \
 \
 && UNATTENDED=1 ./build.sh \
 && UNATTENDED=1 ./build_gcc.sh \
 && UNATTENDED=1 ./build_llvm_dsymutil.sh \
 && UNATTENDED=1 ./tools/osxcross-macports install zlib \
 \
 && cd / \
 && apt-get purge -y --auto-remove \
        clang \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
 && mv /osxcross/target /osxcross-target \
 && rm -rf /osxcross \
 && mkdir /osxcross \
 && mv /osxcross-target /osxcross/target \
 \
 && apt-get install -y --no-install-recommends ccache \
 && rm -r /var/lib/apt/lists/* \
 && ln -s ../../bin/ccache /usr/lib/ccache/x86_64-apple-darwin14-gcc \
 && ln -s ../../bin/ccache /usr/lib/ccache/x86_64-apple-darwin14-g++ \
 && ln -s /osxcross/target/macports/pkgs/opt/local/lib/libz.dylib /usr/lib/libz.dylib \
 && ln -s /bin/true /osxcross/target/bin/install_name_tool
