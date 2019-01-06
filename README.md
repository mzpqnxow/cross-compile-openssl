# cross-compile-openssl

Idiot's guide to cross compiling static OpenSSL libraries for MIPS, ARM, etc.. using MUSL libc

## Step 1 - Build / Obtain a musl libc Toolchain

I prefer the following steps. In this specific case, let's assume we need to build a tool that relies on OpenSSL and needs to run on a MIPS based system, but we are stuck with an x86_64 system. We don't want to use buildroot because it's a bit heavyweight, and we don't want to use a QEMU MIPS distribution either, for the same reasons. Here's one way you can get the job done and produce libssl.a and libcrypto.a which can then be statically linked into your program.

### Build a musl toolchain with musl-cross-make

```
$ git clone https://github.com/richfelker/musl-cross-make
$ cd musl-cross-make
$ vi config.mak  # Read config.make.dist or see the example config.make I included in *this* repository
$ make -j && make install
```

You should then proceed by mailing Rich Felker $5USD.

### Use the `activate` script after copying it into your new toolchain root to get your environment set up nicely

Copy the `activate-musl-toolchain.env` file in this repository to the root of the toolchain you just built and installed

```
$ cp activate-musl-toolchain.env /toolchains/mipsel-sf-sysv/activate
$ source /toolchains/mipsel-sf-sysv/activate
```

The activate script comes from a set of scripts I use for doing 'one-off' cross-compiles of packages. The latest version(s) can usually be found @ (here)[https://github.com/mzpqnxow/gdb-static-cross/tree/master/activate-script-helpers]

At this point, some things will "just work" such as `gcc`, `as`, `ld`, etc.. there will also be some variables set that point to static libraries that are commonly needed when building software.

### Grab and extract OpenSSL

This is not hard. (https://www.openssl.org/downloads)[https://www.openssl.org/downloads] has the various versions. You may need a specific one depending on the project you're working on. I can't tell you which version to use.

```
$ wget https://www.openssl.org/source/openssl-1.0.2q.tar.gz
$ tar -xvzf openssl-1.0.2q.tar.gz && cd openssl-1.0.2q
```

### Configure for your architecture (the "hard" part)

OpenSSL uses a relatively peculiar build system instead of the more common `./configure` or `cmake` style build. Since the environment is set with our toolchain info, try the following. We are going to assume for the sake of the example that you are building for mipsel-sf-sysv (lttle-endian mips with software floating point support) and that our musl toolchain is installed in /toolchains/mipsel-sf-sysv

```
export CROSS_SSL_TARGET="$(gcc -v 2>&1 | grep Target | cut -d ' ' -f 2)" # e.g. mipsel-sf-linux-musl
export OPENSSL_ARCH="linux-mips32" # This value is chosen from the output of ./Configure, it is specific to OpenSSL, you can try linux-generic
export CROSS_SSL_TOOLCHAINS="/toolchains" #  This must match the root of where you put your built toolchains
export CROSS_SSL_ARCH="mipsel-sf-sysv" #  This must match the toolchain name in config.mak in musl-cross-make
export CROSS_SSL_BIN="$(dirname $(which gcc))" #  Only works if you used the activate script first
export CROSS_SSL_CMD_PREFIX="${CROSS_SSL_BIN}/${TOOLCHAIN_TARGET}"-
export CROSS_SSL_INC="${TOOLCHAIN_ROOT}/include"
export CROSS_SSL_LIB="${TOOLCHAIN_ROOT}/lib"
./Configure --cross-compile-prefix="${CROSS_SSL_CMD_PREFIX}" -I"${CROSS_SSL_INC}" -L"{CROSS_SSL_LIB}" --prefix="${TOOLCHAIN_ROOT}" "${OPENSSL_ARCH}"
make -j && make install
...
```

At this point, you should be all set, though expect to get errors due to mistakes you made or due to edge cases that pop up . Just remember there are assumptions here that **require** the use of the activate script in the root of this repository. It must be placed in the root of the "installed" musl toolchain, and it must be `sourced` from **bash**, not zsh, not csh, etc, etc..

### Easy part .. make it

```
$ make -j && make install
```

## Now what?

Well, now you can build your application and link it (probably statically) against this new OpenSSL library that you have installed, using the toolchain filesystem layout as if it were a system root. You can follow this exact same process, and for many things will be able to use the `cross_configure` shell alias provided by the activate script. Some gotchas: make sure you have the `-L` and `-I` paths set correctly when cross-compiling the application. Without these set, the OpenSSL libraries and headers will not be found. You'll find some software packages are simple and lightning quick to cross-compile while others have non-conformation build systems that give headaches- for example, lsof is a bit of a pain. That's all, good luck.

