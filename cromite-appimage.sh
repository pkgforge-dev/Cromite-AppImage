#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=Cromite
ICON="https://github.com/pkgforge-dev/Cromite-AppImage/blob/main/Cromite.png?raw=true"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
APPRUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/AppRun-generic"
NHOOK="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/fix-namespaces.hook"

CROMITE_URL=$(wget -q --retry-connrefused --tries=30 \
	https://api.github.com/repos/uazo/cromite/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*-lin64.tar.gz$" | head -1)

VERSION="$(echo "$CROMITE_URL" | awk -F'-|/' 'NR==1 {print $(NF-3)}')"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage
export URUNTIME_PRELOAD=1 # really needed here

# Prepare AppDir
mkdir -p ./AppDir
wget --retry-connrefused --tries=30 "$CROMITE_URL"
tar xvf ./*.tar.*
rm -f ./*.tar.*
mv -v ./chrome-lin ./AppDir/bin

# we need to remove this because chrome otherwise dlopen libQt5Core on the host when present
rm -f ./AppDir/bin/libqt5_shim.so

wget --retry-connrefused --tries=30 "$ICON" -O ./AppDir/"$PACKAGE".png
cp -v ./AppDir/"$PACKAGE".png ./AppDir/.DirIcon

echo '[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=$PACKAGE
Exec=chrome %U
Terminal=false
Icon=$PACKAGE
StartupWMClass=Chromium-browser
Type=Application
Categories=Application;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;' > ./AppDir/"$PACKAGE".desktop

# strip cromite bundled libs
strip -s -R .comment --strip-unneeded ./AppDir/bin/lib*.so*

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
export DST_DIR="$PWD"/AppDir
./quick-sharun l -p -v -s -e -k ./AppDir/bin/chrome -- google.com --no-sandbox
DEPLOY_OPENGL=1 DEPLOY_VULKAN=1 \
	DEPLOY_PIPEWIRE=1 DEPLOY_QT=1 \
	./quick-sharun l -p -v -s -k  \
	./AppDir/bin/chrome_*         \
	/usr/lib/libelogind.so*       \
	/usr/lib/libnss*              \
	/usr/lib/libsoftokn3.so       \
	/usr/lib/libfreeblpriv3.so    \
	/usr/lib/libcloudproviders*   \
	/usr/lib/pkcs11/*

# Weird
ln -s ../bin/chrome ./AppDir/shared/bin/exe

# get AppRun and fix ubuntu nonsense hook
wget --retry-connrefused --tries=30 "$APPRUN" -O ./AppDir/AppRun
wget --retry-connrefused --tries=30 "$NHOOK" -O ./AppDir/bin/fix-namespaces.hook
chmod +x ./AppDir/AppRun ./AppDir/bin/fix-namespaces.hook

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
	--appbundle-id="$PACKAGE-$VERSION" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "$PACKAGE-$VERSION-anylinux-$ARCH.dwfs.AppBundle" \
	--disable-use-random-workdir # speeds up launch time

zsyncmake *.AppBundle -u *.AppBundle
