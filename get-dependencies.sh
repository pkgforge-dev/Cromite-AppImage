#!/bin/sh

set -ex
ARCH="$(uname -m)"

echo "Installing dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel \
	chromium \
	curl \
	desktop-file-utils \
	git \
	glu \
	gtk3 \
	gtkmm3 \
	gvfs \
	highway \
	libepoxy \
	libheif \
	libjxl \
	libsm \
	libtiff \
	libva \
	libxcb \
	mesa \
	nss \
	patchelf \
	pipewire-audio \
	pulseaudio-alsa \
	strace \
	vulkan-intel \
	vulkan-mesa-layers \
	vulkan-nouveau \
	vulkan-radeon \
	wayland \
	wget \
	x265 \
	xcb-util-cursor \
	xcb-util-keysyms \
	xcb-util-wm \
	xorg-server-xvfb \
	zsync

case "$ARCH" in
	'x86_64')  
		PKG_TYPE='x86_64.pkg.tar.zst'
		pacman -Syu --noconfirm intel-media-driver libva-intel-driver vulkan-intel haskell-gnutls svt-av1
		;;
	'aarch64') 
		PKG_TYPE='aarch64.pkg.tar.xz'
		pacman -Syu --noconfirm vulkan-freedreno vulkan-panfrost
		;;
	''|*)      
		echo "Unknown cpu arch: $ARCH" 
		exit 1
		;;
esac

LLVM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/llvm-libs-nano-$PKG_TYPE"
LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
FFMPEG_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/ffmpeg-mini-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-mini-$PKG_TYPE"
VK_RADEON_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-radeon-mini-$PKG_TYPE"
VK_INTEL_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-intel-mini-$PKG_TYPE"
VK_NOUVEAU_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-nouveau-mini-$PKG_TYPE"
VK_PANFROST_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-panfrost-mini-$PKG_TYPE"
VK_FREEDRENO_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-freedreno-mini-$PKG_TYPE"
VK_BROADCOM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/vulkan-broadcom-mini-$PKG_TYPE"

echo "Installing debloated pckages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LLVM_URL"        -O  ./llvm-libs.pkg.tar.zst
wget --retry-connrefused --tries=30 "$LIBXML_URL"      -O  ./libxml2.pkg.tar.zst
wget --retry-connrefused --tries=30 "$FFMPEG_URL"      -O  ./ffmpeg.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"        -O  ./opus-nano.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"        -O  ./mesa.pkg.tar.zst
wget --retry-connrefused --tries=30 "$VK_RADEON_URL"   -O  ./vulkan-radeon.pkg.tar.zst
wget --retry-connrefused --tries=30 "$VK_NOUVEAU_URL"  -O  ./vulkan-nouveau.pkg.tar.zst

if [ "$ARCH" = 'x86_64' ]; then
	wget --retry-connrefused --tries=30 "$VK_INTEL_URL"     -O ./vulkan-intel.pkg.tar.zst
else
	wget --retry-connrefused --tries=30 "$VK_PANFROST_URL"  -O ./vulkan-panfrost.pkg.tar.zst
	wget --retry-connrefused --tries=30 "$Vk_FREEDRENO_URL" -O ./vulkan-freedreno.pkg.tar.zst
	wget --retry-connrefused --tries=30 "$Vk_BROADCOM_URL"  -O ./vulkan-broadcom.pkg.tar.zst
fi

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst

echo "All done!"
echo "---------------------------------------------------------------"
