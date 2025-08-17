#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

CROMITE_URL=$(wget -q --retry-connrefused --tries=30 \
	https://api.github.com/repos/uazo/cromite/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*-lin64.tar.gz$" | head -1)

VERSION="$(echo "$CROMITE_URL" | awk -F'-|/' 'NR==1 {print $(NF-3)}')"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

export ADD_HOOKS="self-updater.bg.hook:fix-namespaces.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=Cromite-"$VERSION"-anylinux-"$ARCH".AppImage
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1
export DEPLOY_QT=1
export URUNTIME_PRELOAD=1 # really needed here

# Prepare AppDir
mkdir -p ./AppDir
wget --retry-connrefused --tries=30 "$CROMITE_URL"
tar xvf ./*.tar.*
rm -f ./*.tar.*
mv -v ./chrome-lin ./AppDir/bin

# we need to remove this because chrome otherwise dlopen libQt5Core on the host when present
rm -f ./AppDir/bin/libqt5_shim.so

# strip cromite bundled libs
strip -s -R .comment --strip-unneeded ./AppDir/bin/lib*.so*

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun ./AppDir/bin/chrome -- google.com --no-sandbox
./quick-sharun                    \
	./AppDir/bin/chrome_*         \
	/usr/lib/libelogind.so*       \
	/usr/lib/libnss*              \
	/usr/lib/libsoftokn3.so       \
	/usr/lib/libfreeblpriv3.so    \
	/usr/lib/libcloudproviders*   \
	/usr/lib/pkcs11/*

# Weird
ln -s ../bin/chrome ./AppDir/shared/bin/exe

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

# Set up the PELF toolchain
wget --retry-connrefused --tries=30 \
	"https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" -O ./pelf
chmod +x ./pelf

echo "Generating [dwfs]AppBundle...(Go runtime)"
./pelf --add-appdir ./AppDir \
	--appbundle-id="Cromite-$VERSION" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "Cromite-$VERSION-anylinux-$ARCH.dwfs.AppBundle" \
	--disable-use-random-workdir # speeds up launch time

zsyncmake *.AppBundle -u *.AppBundle
