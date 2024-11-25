#!/bin/sh

set -eu

PACKAGE=cromite
ICON="https://camo.githubusercontent.com/6b4ee03be91712db2d81b603a1bb83553e97b66fa49443bf27b641089ea51696/68747470733a2f2f7777772e63726f6d6974652e6f72672f6170705f69636f6e2e706e67"

CROMITE_URL=$(wget -q --retry-connrefused --tries=30 \
	https://api.github.com/repos/uazo/cromite/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*-lin64.tar.gz$" | head -1)

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
export VERSION="$(echo "$CROMITE_URL" | awk -F'/' 'NR==1 {print $(NF-1)}')"

UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BIN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME=$(wget -q --retry-connrefused --tries=30 \
	https://api.github.com/repos/VHSgunzo/uruntime/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*appimage.*dwarfs.*$ARCH$" | head -1)

# Prepare AppDir
mkdir -p ./"$PACKAGE"/AppDir/shared
cd ./"$PACKAGE"/AppDir
wget --retry-connrefused --tries=30 "$CROMITE_URL"
tar xvf *.tar.*
rm -f *.tar.*
mv ./chrome-lin ./bin
ln -s ../bin ./shared/lib
ln -s ./shared ./usr
ln -s ./usr/share ./share

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$LIB4BIN" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -d -- ./lib4bin -p -v -r -s -e ./bin/chrome*

cp -rv /usr/share/glvnd   ./usr/share
cp -rv /usr/share/vulkan  ./usr/share
cp -rv /usr/share/X11     ./usr/share
sed -i 's|/usr/lib/||g'   ./usr/share/vulkan/icd.d/*

cp -v /usr/lib/libsoftokn3.so ./shared/lib
ldd ./shared/lib/libsoftokn3.so \
	| awk -F"[> ]" '{print $4}' | xargs -I {} cp -vn {} ./lib

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
Type=Application
Categories=Application;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;
EOF

wget --retry-connrefused --tries=30 "$ICON" -O "$PACKAGE".png
ln -s ./"$PACKAGE".png ./.DirIcon

# Prepare sharun
echo "Preparing sharun..."
ln -s ./bin/chrome ./AppRun
./sharun -g

# MAKE APPIMAGE WITH URUNTIME
cd ..
wget -q "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

#Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
printf "$UPINFO" > data.upd_info
llvm-objcopy --update-section=.upd_info=data.upd_info \
	--set-section-flags=.upd_info=noload,readonly ./uruntime
printf 'AI\x02' | dd of=./uruntime bs=1 count=3 seek=8 conv=notrunc

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S22 -B16 \
	--header uruntime \
	-i ./AppDir -o "$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

mv ./*.AppImage* ../
cd ..
rm -rf ./"$PACKAGE"
echo "All Done!"
