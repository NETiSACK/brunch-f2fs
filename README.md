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

**This project still in experimental and in-development state.**

**Please take a look at [Brunch Framework by sebanc][bruch-framework] and [F2FS][f2fs] first if you don't know what this fork about.**

**This fork and I will not take any responsibility If anything bad happened to your device.**

F2FS is a best performance and higher longevity for Flash-memory based storage like eMMC, widely used on Android and embedded Linux systems but also known for data lost and corruption upon dirty shutdown.

So, this project is suitable for battery-enabled devices like Tablet PC or cheap laptop with eMMC storage, though you should play safe by sync your files every time.

**Please take your own risk.**

<!-- Project Brief -->
## About This Fork

This is a modified version of sebanc's Brunch Framework, replacing every ext2/4 partitions with F2FS Filesystem.

Following partitions will be formatted as F2FS:
- STATE
- ROOT-A
- ROOT-B
- ROOT-C
- OEM

See more about ChromeOS partition scheme: [ChromiumOS Drive Partitions][chromiumos-drive-partitions]

**Installing from host OS system into target disk will still in original ext2/ext4 partitions until installing into internal disk like eMMC inside USB Boot, which done by `chromeos-install` command from ChromeOS itself.**

**So, full disk installation by USB Boot is required to preventing this [issue][data-corruption-f2fs].**

**Then, USB Boot will always using older kernel as default for creating F2FS partition.**

This fork also using these kernel patches:
- [BORE Scheduler][bore-scheduler]

Brunch Framework with F2FS also containing these features:
- Configurable graceful shutdown before battery almost running out (using PWA or tty2 as root)
- Configurable BORE Scheduler (using PWA or tty2 as root)

## Install Instructions

See [Bruch Framework by sebanc Install Instructions][brunch-framework-install-instructions]

Note: There will likely no support for linuxloops.

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
[data-corruption-f2fs]: https://bugs.archlinux.org/task/69363
