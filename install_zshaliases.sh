#!/usr/bin/env zsh
currentDir=$(cd $(dirname "$0") && pwd)
pathbashglobal="$currentDir/dotfiles/.bash_aliases_global"
cp "$currentDir/dotfiles/.bash_aliases" ~/.bash_aliases
sed -i "1 i source $pathbashglobal" ~/.bash_aliases
