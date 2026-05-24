<div align="center">

# Cromite-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/Cromite-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/Cromite-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest)
[![Latest Stable Release](https://img.shields.io/github/v/release/pkgforge-dev/Cromite-AppImage)](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest)

<p align="center">
  <img src="https://github.com/pkgforge-dev/Cromite-AppImage/blob/main/AppDir/Cromite.png?raw=true" width="128" />
</p>


| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/Cromite-AppImage/releases/latest) | [Click here](https://github.com/uazo/cromite) |

</div>

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun) and its wrapper [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks. 

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i cromite` or `appman -i cromite`

* [dbin](https://github.com/xplshn/dbin) `dbin install cromite.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install cromite`

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed, you will be prompted for permission to check for updates and if agreed you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

---

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
