<div id="top"></div>

<!-- Shields/Logos -->
[![License][license-shield]][license-url]
[![Issues][issues-shield]][issues-url]

<!-- Project Logo -->
<p align="center">
  <a href="https://github.com/NETiSACK/brunch-f2fs" title="Brunch">
   <img src="./Images/decon_icon-512.png" width="128px" alt="Logo"/>
  </a>
</p>
<h1 align="center">Brunch Framework with F2FS</h1>

<!-- Warning -->
## Warning

This project still in experimental and in-development state!

Please take a look at [Brunch Framework by sebanc][bruch-framework] and [F2FS][f2fs] first if you don't know what this fork about.

This fork and I will not take any responsibility If anything bad happened to your device.

F2FS is a best performance and higher longevity for Flash-memory based storage like eMMC, but also known for data lost and corruption upon dirty shutdown.

So, this project is suitable for battery-enabled devices like Tablet PC or cheap laptop with eMMC storage.

Please take your own risk.

<!-- Project Brief -->
## About This Fork

This is a modified version of sebanc's Brunch Framework, replacing every ext2/4 partitions with F2FS Filesystem.

Following partitions will be formatted as F2FS upon install and update:
- STATE
- ROOT-A
- ROOT-B
- ROOT-C
- OEM

See more about ChromeOS partition scheme: [ChromiumOS Drive Partitions][chromiumos-drive-partitions]

This fork also using additional kernel patches:
- [Kernel Compiler Patch by graysky2][kernel-compiler-patch]
- [BORE Scheduler][bore-scheduler]

## Install Instructions

See [Bruch Framework by sebanc Install Instructions][brunch-framework-install-instructions]

Note: There is no support for linuxloops yet.

<!-- Reference Links -->
<!-- Badges -->
[license-shield]: https://img.shields.io/github/license/NETiSACK/brunch-f2fs?label=License&logo=Github&style=flat-square
[license-url]: ./LICENSE
[issues-shield]: https://img.shields.io/github/issues/NETiSACK/brunch-f2fs?label=Issues&logo=Github&style=flat-square
[issues-url]: https://github.com/NETiSACK/brunch-f2fs/issues

<!-- Outbound Links -->
[bruch-framework]: https://github.com/sebanc/brunch
[f2fs]: https://en.wikipedia.org/wiki/F2FS
[chromiumos-drive-partitions]: https://chromium.googlesource.com/chromiumos/docs/+/4cc01f100c5fa7c675dce8ad3742f9c00726f506/disk_format.md#drive-partitions
[brunch-framework-install-instructions]: https://github.com/sebanc/brunch#install-instructions
[kernel-compiler-patch]: https://github.com/graysky2/kernel_compiler_patch
[bore-scheduler]: https://github.com/firelzrd/bore-scheduler