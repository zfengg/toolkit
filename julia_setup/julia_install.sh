#!/usr/bin/env bash

# install julia on Linux x86_64 machine
# run with `sudo`

PATH_DOWNLOAD="$HOME/Downloads"
PATH_USRBIN="/usr/local/bin"
DIR_INSTALL="/opt"
tarball="julia-$1-linux-x86_64.tar.gz"
linkDownload="https://julialang-s3.julialang.org/bin/linux/x64/${1:0:3}/$tarball"

echo "downloading the julia tar-ball:"
wget --directory-prefix $PATH_DOWNLOAD $linkDownload
echo ":) download finished!"

echo ">>> unpack tarball to the dirIntall"
sudo tar -xvzf "$PATH_DOWNLOAD/$tarball" --directory=$DIR_INSTALL
echo ":) julia tarball unpacked at $DIR_INSTALL/julia-$1/ !"

echo "creating symbolic link"
sudo ln -s "$DIR_INSTALL/julia-$1/bin/julia" "$PATH_USRBIN/julia$1"
# replace the default julia command
if [ -n "$2" ]; then
        sudo rm "$PATH_USRBIN/$2"
        sudo ln -s "$DIR_INSTALL/julia-$1/bin/julia" "$PATH_USRBIN/$2"
fi
echo ":) symbolic links created!"

echo "removing the downloaded tarball"
rm "$PATH_DOWNLOAD/$tarball"
echo ":) tarball removed!"

if [ -n "$2" ]; then
        echo ":) All finished!!! Please check by running: julia$1 or $2 "
else
        echo ":) All finished!!! Please check by running: julia$1 "
fi
