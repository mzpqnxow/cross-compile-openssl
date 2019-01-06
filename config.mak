#
# This is for musl-cross-make
# Important: the type of architecture that will be built depends on the
# toolchain name, so make sure you don't just put gibberish in there. You
# can see examples in the musl-cross-config repository
#
# Feel free to adjust options if necessary, but you shouldn't need to do
# much here other than copy this file into the musl-cross-make directory
#

# This is used in a path so no slashes
TOOLCHAIN_NAME = "mipsel-sf-sysv"
TARGET = mipsel-sf-linux-musl
PROJECT_HOME = https://github.com/mzpqnxow/musl-cross-make-configs
OUTPUT = /toolchains/$(TOOLCHAIN_NAME)
# Build options
COMMON_CONFIG += CFLAGS="-pipe -g0 -Os" CXXFLAGS="-pipe -g0 -Os" LDFLAGS="-s"
COMMON_CONFIG += --disable-nls
COMMON_CONFIG += --with-debug-prefix-map=$(CURDIR)=
# Architecture, ABI, FP support
# You'll always want soft FP for tinkering in case you have an old
# CPU that does not support floating point operations in hardware
# Do you *really* care about performance? I think probably not..
GCC_CONFIG += --with-float=soft
# Disable large file support for portability with (very) old systems
# GCC_CONFIG += --disable-largefile
# NLS
GCC_CONFIG += --disable-nls
# Language support
GCC_CONFIG += --enable-languages=c,c++
# Extras
GCC_CONFIG += --disable-libgomp
GCC_CONFIG += --disable-libmudflap
GCC_CONFIG += --disable-libsanitizer
GCC_CONFIG += --disable-libssp
GCC_CONFIG += --disable-target-libbacktrace
# Thread support w/o thread local storage
# GCC will emulate TLS w/pthread libs
# GCC_CONFIG += --enable-threads
# GCC_CONFIG += --disable-tls
# No thread support
# GCC_CONFIG += --disable-threads
# GCC_CONFIG += --disable-tls
GCC_CONFIG += --with-pkgversion=musl-cross-make/$(TOOLCHAIN_NAME)/`date -I`
GCC_CONFIG += --with-bugurl="$(PROJECT_HOME)"

