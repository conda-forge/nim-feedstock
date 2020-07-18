#!/usr/bin/env bash

# based on https://github.com/bioconda/bioconda-recipes/tree/master/recipes/pb-falconc

set -vexu -o pipefail

pushd nim

# inject compilers
cc=clang
ldflags="${LDFLAGS}"
if [[ ${target_platform} =~ linux.* ]]; then
    cc=gcc
    ldflags="${ldflags} -ldl"
fi
cat <<EOF >> config/nim.cfg
cc = "${cc}"
gcc.exe = "$(basename "${CC}")"
gcc.cpp.exe = "$(basename "${CC}")"
gcc.linkerexe = "$(basename "${CC}")"
clang.exe = "$(basename "${CC}")"
clang.linkerexe = "$(basename "${CC}")"
gcc.options.linker = "${ldflags}"
gcc.cpp.options.linker = "${ldflags}"
clang.options.linker = "${ldflags}"
clang.cpp.options.linker = "${ldflags}"
EOF

./build.sh
bin/nim c koch
./koch tools

ls -larth
ls -larth bin/
ls -larth lib/
ls -larth config/

build_dir=$(pwd)

mkdir -p "${PREFIX}"
cd "${PREFIX}"
rsync -av "${build_dir}"/bin .
rsync -av "${build_dir}"/lib .
rsync -av "${build_dir}"/config .
