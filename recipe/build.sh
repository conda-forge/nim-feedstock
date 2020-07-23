#!/usr/bin/env bash

# based on https://github.com/bioconda/bioconda-recipes/tree/master/recipes/pb-falconc

set -vexu -o pipefail

pushd nim

# inject compilers
if [[ ${target_platform} =~ linux.* ]]; then

cat <<'EOF' >> config/nim.cfg
gcc.exe %= "$GCC"
gcc.cpp.exe %= "$GXX"
gcc.linkerexe %= "$GCC"
gcc.options.linker %= "$LDFLAGS -ldl"
gcc.cpp.options.linker %= "$LDFLAGS -ldl"

gcc.options.always %= "$CPPFLAGS $CFLAGS ${gcc.options.always}"
gcc.cpp.options.always %= "$CPPFLAGS $CFLAGS ${gcc.cpp.options.always}"
EOF

else

cat <<'EOF' >> config/nim.cfg
clang.exe %= "$CLANG"
clang.cpp.exe %= "$CLANGXX"
clang.linkerexe %= "$CLANG"
clang.options.linker %= "$LDFLAGS"
clang.cpp.options.linker %= "$LDFLAGS"

clang.options.always %= "$CPPFLAGS $CFLAGS ${gcc.options.always}"
clang.cpp.options.always %= "$CPPFLAGS $CFLAGS ${gcc.cpp.options.always}"
EOF

fi

./build.sh
bin/nim c koch
./koch boot -d:release
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
