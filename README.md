# Background
The naming, Perf Neon, is inspired by a Linux Distribution called KDE Neon, where KDE take latest Ubuntu LTS as a base system and then put Latest KDE on top of it. Same thing as Perf Neon, where i take whatever the world the LineageOS team put under [LineageOS/android_kernel_xiaomi_sm6125](https://github.com/LineageOS/android_kernel_xiaomi_sm6125) and then put minimal patches on top of it.

# What is it for?
While it's mostly used for another kernel developers to compare their work with a literal close-to-stock kernel, it's also fulfill the dream of a purists, where they want everything stable but also wanted extra spices on top of it.

# Release schedules
This kernel follows weekly builds of [devices/ginkgo/builds](https://download.lineageos.org/devices/ginkgo/builds), you will get a new kernel build every sunday. You might need to check out the GitHub repo for new releases.

# Compatibility
Compatible with official LineageOS builds for Redmi Note 8, but since this kernel strictly follows [LineageOS/android_kernel_xiaomi_sm6125](https://github.com/LineageOS/android_kernel_xiaomi_sm6125), the compatibility may vary between each releases. Always make sure you have a kernel backup before proceeding. This kernel might gonna work on non-lineage based roms but it is not guaranteed.

# Credits
[TBYOOL](https://github.com/tbyool) for the buildscripts and kernel patches.   
[backslashxx](https://github.com/backslashxx) for ksu scope-minimized manual hooks.   
[KernelSU-Next](https://github.com/KernelSU-Next) for KernelSU Next.   
