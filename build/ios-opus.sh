#!/bin/bash

if [[ -z ${ARCH} ]]; then
    echo -e "(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${IOS_MIN_VERSION} ]]; then
    echo -e "(*) IOS_MIN_VERSION not defined\n"
    exit 1
fi

if [[ -z ${TARGET_SDK} ]]; then
    echo -e "(*) TARGET_SDK not defined\n"
    exit 1
fi

if [[ -z ${SDK_PATH} ]]; then
    echo -e "(*) SDK_PATH not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "(*) BASEDIR not defined\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/ios-common.sh

# PREPARING PATHS & DEFINING ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="opus"
set_toolchain_clang_paths ${LIB_NAME}

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURING IF REQUESTED
if [[ ${RECONF_opus} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/ios-$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --enable-rtcd \
    --enable-asm \
    --enable-check-asm \
    --enable-custom-modes \
    --disable-shared \
    --disable-fast-install \
    --disable-maintainer-mode \
    --disable-doc \
    --disable-extra-programs \
    --disable-ambisonics \
    --host=${TARGET_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./opus.pc ${INSTALL_PKG_CONFIG_DIR}

make install || exit 1
