#!/usr/bin/env bash

PATH_USRBIN="/usr/local/bin"
DIR_INSTALL="/opt"

sudo rm -rf "$DIR_INSTALL/julia-$1"
echo "installation dir: $DIR_INSTALL/julia-$1 removed!"

sudo rm "$PATH_USRBIN/julia$1"
echo "symbolic link: $PATH_USRBIN/julia$1 removed!"
