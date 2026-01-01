#!/bin/bash
##################################################
# Unofficial LineageOS Perf kernel Compile Script
# Based on the original compile script by vbajs
# Forked by Riaru Moda
##################################################

# Help message
help_message() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --ksu     Enable KernelSU support"
  echo "  --help    Show this help message"
}

# Environment setup
setup_environment() {
  echo "Setting up build environment..."
  export ARCH=arm64
  export KBUILD_BUILD_USER=riaru-hiyorun
  export KBUILD_BUILD_HOST=ximiedits
  export GCC64_DIR=$PWD/gcc64
  export GCC32_DIR=$PWD/gcc32
  export KSU_SETUP_URI="https://github.com/KernelSU-Next/KernelSU-Next"
  export KSU_BRANCH="legacy"
}

# Toolchain setup
setup_toolchain() {
  echo "Setting up toolchains..."

  if [ ! -d "$PWD/clang" ]; then
    echo "Cloning Clang..."
    git clone https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b --depth=1 clang
  else
    echo "Local clang dir found, using it."
  fi

  if [ ! -d "$PWD/gcc32" ] && [ ! -d "$PWD/gcc64" ]; then
    echo "Cloning GCC..."
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git --depth=1 gcc64
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git --depth=1 gcc32
  else
    echo "Local gcc dirs found, using them."
  fi
}

# Update PATH
update_path() {
  echo "Updating PATH..."
  export PATH="$PWD/clang/bin/:$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH"
}

# General Patches
add_patches() {
  echo "Adding patches..."
  wget -L https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder/-/raw/main/patches/4.14/add-rtl88xxau-5.6.4.2-drivers.patch -O rtl88xxau.patch
  patch -p1 < rtl88xxau.patch
  wget -L https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder/-/raw/main/patches/4.14/add-wifi-injection-4.14.patch -O wifi-injection.patch
  patch -p1 < wifi-injection.patch
  sed -i 's/# CONFIG_PID_NS is not set/CONFIG_PID_NS=y/' arch/arm64/configs/vendor/trinket-perf_defconfig
  echo "CONFIG_POSIX_MQUEUE=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
  echo "CONFIG_SYSVIPC=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
  echo "CONFIG_CGROUP_DEVICE=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
  echo "CONFIG_DEVTMPFS=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
  echo "CONFIG_IPC_NS=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
  echo "CONFIG_DEVTMPFS_MOUNT=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
}

# add_dtbo() {
#   echo "Adding dtbo compile support..."
#   wget -L "https://github.com/Skyblueborb/android_kernel_xiaomi_sm6125/commit/3ff2c3fc8a18a805029ab1de6f2cca9908bbc2ba.patch" -O dtbo.patch
#   patch -p1 < dtbo.patch
# }

# KSU Setup
setup_ksu() {
  local arg="$1"
  if [[ "$arg" == "--ksu" ]]; then
    echo "Setting up KernelSU..."
    echo "CONFIG_KSU=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
    echo "CONFIG_KSU_LSM_SECURITY_HOOKS=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
    echo "CONFIG_KSU_MANUAL_HOOKS=y" >> arch/arm64/configs/vendor/trinket-perf_defconfig
    wget -L "https://github.com/ximi-mojito-test/mojito_krenol/commit/8e25004fdc74d9bf6d902d02e402620c17c692df.patch" -O ksu.patch
    patch -p1 < ksu.patch
    patch -p1 < ksumakefile.patch
    patch -p1 < umount.patch
    git clone "$KSU_SETUP_URI" -b "$KSU_BRANCH" KernelSU
    cd drivers
    ln -sfv ../KernelSU/kernel kernelsu
    cd ..
  else
    echo "KernelSU setup skipped."
  fi
}

# Compile kernel
compile_kernel() {
  echo -e "\nStarting compilation..."
  sed -i 's/CONFIG_LOCALVERSION="-perf"/CONFIG_LOCALVERSION="-perf-neon"/' arch/arm64/configs/vendor/trinket-perf_defconfig
  make O=out ARCH=arm64 vendor/trinket-perf_defconfig
  make O=out ARCH=arm64 vendor/xiaomi-trinket.config
  make O=out ARCH=arm64 vendor/ginkgo.config
  make -j$(nproc --all) O=out \
    ARCH=arm64 \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    AS=llvm-as \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CLANG_TRIPLE=aarch64-linux-gnu-
}

# Main function
main() {
  case "$1" in
    --help)
      help_message
      exit 0
      ;;
  esac
  setup_environment
  setup_toolchain
  update_path
  add_patches
  # add_dtbo
  setup_ksu "$1"
  compile_kernel
}

# Run the main function
main "$1"
