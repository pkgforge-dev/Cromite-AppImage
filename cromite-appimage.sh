#!/bin/sh

set -eux

PACKAGE=Cromite
ICON="https://github.com/pkgforge-dev/Cromite-AppImage/blob/main/Cromite.png?raw=true"

CROMITE_URL=$(wget -q --retry-connrefused --tries=30 \
	https://api.github.com/repos/uazo/cromite/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*-lin64.tar.gz$" | head -1)

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
export VERSION="$(echo "$CROMITE_URL" | awk -F'-|/' 'NR==1 {print $(NF-3)}')"
echo "$VERSION" > ~/version

UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BIN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"

# Prepare AppDir
mkdir -p ./AppDir
cp -v ./detect-nonsense.sh ./AppDir
cd ./AppDir

wget --retry-connrefused --tries=30 "$CROMITE_URL"
tar xvf ./*.tar.*
rm -f ./*.tar.*
mv ./chrome-lin ./bin

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$LIB4BIN" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -a -- ./lib4bin -p -v -s -e -k ./bin/chrome -- google.com --no-sandbox
./lib4bin -p -v -s -k ./bin/chrome_* \
	/usr/lib/lib*GL* \
	/usr/lib/libvulkan* \
	/usr/lib/libVkLayer* \
	/usr/lib/dri/* \
	/usr/lib/vdpau/* \
	/usr/lib/libxcb-* \
	/usr/lib/libelogind.so* \
	/usr/lib/libwayland* \
	/usr/lib/libnss* \
	/usr/lib/libsoftokn3.so \
	/usr/lib/libfreeblpriv3.so \
	/usr/lib/libgtk* \
	/usr/lib/libgdk* \
	/usr/lib/gdk-pixbuf-*/*/loaders/* \
	/usr/lib/libcloudproviders* \
	/usr/lib/libXcursor.so.1 \
	/usr/lib/libXinerama* \
	/usr/lib/gconv/* \
	/usr/lib/pkcs11/* \
	/usr/lib/gvfs/* \
	/usr/lib/gio/modules/* \
	/usr/lib/pulseaudio/* \
	/usr/lib/alsa-lib/*

# strip cromite bundled libs
strip -s -R .comment --strip-unneeded ./bin/lib*

# Weird
ln -s ../bin/chrome ./shared/bin/exe

# DESKTOP AND ICON
cat > "$PACKAGE".desktop << EOF
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=$PACKAGE
Exec=chrome %U
Terminal=false
Icon=$PACKAGE
StartupWMClass=Chromium-browser
Type=Application
Categories=Application;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;
EOF

wget --retry-connrefused --tries=30 "$ICON" -O "$PACKAGE".png
ln -s ./"$PACKAGE".png ./.DirIcon

# Prepare sharun
echo "Preparing sharun..."
./sharun -g

echo '#!/bin/sh
CURRENTDIR="$(cd "${0%/*}" && echo "$PWD")"
# check if we namespaces restriction from ubuntu before starting cromite
"$CURRENTDIR"/detect-nonsense.sh
exec "$CURRENTDIR"/bin/chrome "$@"
' > ./AppRun
chmod +x ./AppRun ./detect-nonsense.sh

# MAKE APPIMAGE WITH URUNTIME
cd ..
wget -q "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

# Keep the mount point (speeds up launch time)
sed -i 's|URUNTIME_MOUNT=[0-9]|URUNTIME_MOUNT=0|' ./uruntime

#Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime \
	-i ./AppDir -o "$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage

# Set up the PELF toolchain
wget -qO ./pelf "https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH"
chmod +x ./pelf

echo "Generating [dwfs]AppBundle...(Go runtime)"
./pelf --add-appdir ./AppDir \
	--appbundle-id="$PACKAGE-$VERSION" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "$PACKAGE-$VERSION-anylinux-$ARCH.dwfs.AppBundle" \
	--disable-use-random-workdir # speeds up launch time

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage
zsyncmake *.AppBundle -u *.AppBundle

echo "All Done!"
