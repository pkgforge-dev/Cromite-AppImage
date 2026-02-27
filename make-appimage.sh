#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook:fix-namespaces.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1
export DEPLOY_QT=1
export DEPLOY_GTK=1
export DEPLOY_P11KIT=1
export GTK_DIR=gtk-3.0
export URUNTIME_PRELOAD=1 # really needed here

# strip cromite bundled libs
strip -s -R .comment --strip-unneeded ./AppDir/bin/lib*.so*

# Deploy dependencies
quick-sharun ./AppDir/bin/chrome -- google.com --no-sandbox
quick-sharun \
	./AppDir/bin/chrome_*         \
	./AppDir/bin/libqt6_shim.so*  \
	/usr/lib/libQt6Widgets.so*    \
	/usr/lib/libnss*              \
	/usr/lib/libsoftokn3.so       \
	/usr/lib/libfreeblpriv3.so    \
	/usr/lib/libcloudproviders*

# Weird
ln -s ../bin/chrome ./AppDir/shared/bin/exe

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage --no-sandbox
