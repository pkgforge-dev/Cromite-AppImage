#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel          \
	curl                \
	flac                \
	git                 \
	glu                 \
	gvfs                \
	libepoxy            \
	libheif             \
	libjxl              \
	libsm               \
	librsvg             \
	libtiff             \
	libxcb              \
	nss                 \
	pipewire-audio      \
	pulseaudio-alsa     \
	qt6-wayland         \
	vulkan-mesa-layers  \
	wget                \
	xcb-util-cursor     \
	xcb-util-keysyms    \
	xcb-util-wm         \
	xorg-server-xvfb    \
	zsync

if [ "$ARCH" = 'x86_64' ]; then
		pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

echo "Getting binary..."
echo "---------------------------------------------------------------"
CROMITE_URL=$(wget https://api.github.com/repos/uazo/cromite/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi -m 1 "https.*-lin64.tar.gz$")
	
mkdir -p ./AppDir/bin
wget --retry-connrefused --tries=30 "$CROMITE_URL"
tar xvf ./*.tar.*
rm -f ./*.tar.*
mv -v ./chrome-lin/* ./AppDir/bin

# we need to remove this because chrome otherwise dlopen libQt5Core on the host
# when present, we can only bunle libqt6 or libqt5 but not both
rm -f ./AppDir/bin/libqt5_shim.so

echo "$CROMITE_URL" | awk -F'-|/' 'NR==1 {print $(NF-3)}' > ~/version
