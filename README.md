# Cromite-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/Cromite-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/Cromite-AppImage/actions/workflows/blank.yml/badge.svg)](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest)

* [Latest Stable Release](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest)

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks. 

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i cromite` or `appman -i cromite`

* [dbin](https://github.com/xplshn/dbin) `dbin install cromite.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install cromite`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)

---

# Why should I use this? 

AppImage doesn't have security issues that break the internal sandbox of web-browsers. [1](https://librewolf.net/installation/linux/#security) [2](https://seirdy.one/notes/2022/06/12/flatpak-and-web-browsers/) [3](https://github.com/uazo/cromite/issues/1053#issuecomment-2191794660)

**You should be aware that distros like Universal Blue don't care about the security of its users and tell people that only flatpak is supported despite being aware of the security issue.**

* https://github.com/ublue-os/bluefin/issues/2792

<details>
  <summary><b>They even REMOVE comments that suggest using AppImage to fix that issue.</b></summary>
  <img width="933" height="666" alt="image" src="https://github.com/user-attachments/assets/de2bbfe4-b38e-4c0a-9e29-28753e753990" />
  <img width="476" height="62" alt="image" src="https://github.com/user-attachments/assets/ce23ab52-1d7f-4745-ba5b-fc68c45f003b" />
  <img width="927" height="760" alt="image" src="https://github.com/user-attachments/assets/12e08cb3-3d55-4f8e-b5aa-39ced8775c00" />
  </a>
</details>
