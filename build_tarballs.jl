# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build WCS
name = "WCS"
version = v"5.13"
sources = [
    "https://cache.julialang.org/ftp://ftp.atnf.csiro.au/pub/software/wcslib/wcslib-5.13.tar.bz2" =>
    "d6983e8bc5997e625e66cc3b8590745231f1761437d533ad4b99a015eeb9b4e7",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd wcslib-5.13/
sed -i "s/AC_CANONICAL_BUILD/AC_CANONICAL_HOST/; s/build_cpu/host_cpu/; s/build_os/host_os/" configure.ac
wget -O config/config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
patch configure.ac <<EOF
240a241,246
>   *mingw*)
>     SHRLIB="libwcs.dll.\$LIBVER"
>     SONAME="libwcs.dll.\$SHVER"
>     SHRLD="\$SHRLD -shared -Wl,-h\\\$(SONAME)"
>     SHRLN="libwcs.dll"
>     ;;
EOF
autoconf
if [[ "${target}" == *mingw* ]]; then
    ./configure --prefix=$prefix --host=$target --disable-fortran --without-cfitsio --without-pgplot --disable-utils CFLAGS=-DNO_OLDNAMES
else
    ./configure --prefix=$prefix --host=$target --disable-fortran --without-cfitsio --without-pgplot --disable-utils
fi
make
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:powerpc64le, :glibc),
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :musl, :eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libwcs", :libwcs)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

