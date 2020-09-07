# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "titanlib"
version = v"0.2.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/metno/titanlib.git", "4ee6449aeb75a4822832e8285cab95dcea93fe64")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
apk add swig
cd titanlib
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -DBUILD_R=0 -DBUILD_PYTHON=0 -DCMAKE_CXX_FLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
make
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf)
]

platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libtitanlib", :titanlib)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="boost_jll", uuid="28df3c45-c428-5900-9ff8-a3135698ca75"))
    Dependency(PackageSpec(name="GSL_jll", uuid="1b77fbbe-d8ee-58f0-85f9-836ddc23a7a4"))
    Dependency(PackageSpec(name="Python_jll", uuid="93d3a430-8e7c-50da-8e8d-3dfcfb3baf05"))
    Dependency(PackageSpec(name="PROJ_jll", uuid="58948b4f-47e0-5654-a9ad-f609743f8632"))
    Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
