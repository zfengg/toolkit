#!/usr/bin/env bash
currentDir=$(cd $(dirname "$0") && pwd)
pathbashglobal="$currentDir/dotfiles/.bash_aliases_global"
cp "$currentDir/dotfiles/.bash_aliases" ~/.bash_aliases
# sed -i "1 i source $pathbashglobal" ~/.bash_aliases
sed -i "1 i export PATH=\"\$PATH:\$TOOLKIT/bin\"" ~/.bash_aliases
sed -i "1 i export TOOLKIT=$currentDir" ~/.bash_aliases
echo "source $pathbashglobal" >> ~/.bash_aliases
