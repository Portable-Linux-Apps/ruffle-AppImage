#!/bin/sh

set -ex

export ARCH=$(uname -m)
REPO="https://api.github.com/repos/ruffle-rs/ruffle/releases"
APPIMAGETOOL="https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
export URUNTIME_PRELOAD=1 # really needed here

# ruffle uses amd64 instead of x86_64
tarball_url=$(wget "$REPO" -O - | sed 's/[()",{} ]/\n/g' \
	| grep -oi "https.*linux-$ARCH.tar.gz$" | head -1)

export VERSION=$(echo "$tarball_url" | awk -F'/' '{print $(NF-1); exit}')
echo "$VERSION" > ~/version

mkdir ./AppDir && (
	cd ./AppDir
	wget "$tarball_url" -O ./package.tar.gz
	tar xvf ./package.tar.gz
	rm -f ./package.tar.gz
	ln -s ruffle ./AppRun
	cp -v ./extras/* ./
)

wget "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool
./appimagetool -n -u "$UPINFO" ./AppDir


