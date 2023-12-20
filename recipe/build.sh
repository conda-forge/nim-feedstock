#!/usr/bin/env bash

# based on https://github.com/bioconda/bioconda-recipes/tree/master/recipes/pb-falconc

set -vexu -o pipefail

pushd nim

#  Avoid SYS_Random since glibc < 2.25
echo '-d:nimNoGetRandom' >>config/nim.cfg

# inject compilers
if [[ ${target_platform} =~ linux.* ]]; then

	cat <<'EOF' >>config/nim.cfg
gcc.exe %= "$GCC"
gcc.cpp.exe %= "$GXX"
gcc.linkerexe %= "$GCC"
gcc.options.linker %= "$LDFLAGS -ldl"
gcc.cpp.options.linker %= "$LDFLAGS -ldl"

gcc.options.always %= "$CPPFLAGS $CFLAGS ${gcc.options.always}"
gcc.cpp.options.always %= "$CPPFLAGS $CFLAGS ${gcc.cpp.options.always}"
EOF

else

	cat <<'EOF' >>config/nim.cfg
clang.exe %= "$CLANG"
clang.cpp.exe %= "$CLANGXX"
clang.linkerexe %= "$CLANG"
clang.options.linker %= "$LDFLAGS"
clang.cpp.options.linker %= "$LDFLAGS"

clang.options.always %= "$CPPFLAGS $CFLAGS ${gcc.options.always}"
clang.cpp.options.always %= "$CPPFLAGS $CFLAGS ${gcc.cpp.options.always}"
EOF

fi

# https://stackoverflow.com/questions/4247068/sed-command-with-i-option-failing-on-mac-but-works-on-linux
# semi-portable sed
# sed -i'' -e 's/set -e/set -ex/g' build.sh

# osx-arm64 is cross-compiled by osx-amd64
if [[ ${target_platform}  =~ osx-arm64* ]];then
  CPU="arm64"
  CC=${CC_FOR_BUILD} ./build.sh
  bin/nim c \
    --clang.exe:"${CC_FOR_BUILD}" \
    --clang.linkerexe:"$CC_FOR_BUILD" \
    koch
  # koch can't boot strip `nim` with `nim1`
  ./koch boot -d:release --cpu:"$CPU"
else
  ./build.sh
  bin/nim c koch
  ./koch boot -d:release
fi

./koch tools

ls -larth
ls -larth bin/
ls -larth lib/
ls -larth config/

./install.sh "${PREFIX}"
cp -f bin/* "${PREFIX}/nim/bin/"
mkdir -p "${PREFIX}/bin"
for binary in "${PREFIX}/nim/bin/"*; do
	ln -s "${binary}" "${PREFIX}/bin/"
done
