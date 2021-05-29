#!/usr/bin/env bash

# A simple shell script to automate the `copy' workflow in this Repo.

currentDir=$(cd $(dirname "$0") && pwd)

# bash
cp ~/.bashrc $currentDir/dotfiles/
#cp ~/.bash_aliases dotfiles/

# vim
cp ~/.vimrc $currentDir/dotfiles/

# juliaSetup
cp ~/.julia/config/startup.jl $currentDir/julia/
for i in {5..6}; do
	mkdir -p $currentDir/julia/v1.$i && cp ~/.julia/environments/v1.$i/* $currentDir/julia/v1.$i/
done

# cp things to TA_Stuff
ext4cp='tex pdf'
mkdir -p $currentDir/TA/tex/solution
for extTmp in $ext4cp; do
	cp $currentDir/tex/mysolution/mysolution.$extTmp $currentDir/TA/tex/solution/TAsol.$extTmp
done

# add path to this repo to .bash_aliaes
#echo  >> dotfiles/.bash_aliases
#echo "# export the path of current repo" >> dotfiles/.bash_aliases
#echo "export TOOLKIT=\`dirname \$(dirname \$BASH_SOURCE[0])\`" >> dotfiles/.bash_aliases
#echo "alias cdtoolkit=\"cd \$TOOLKIT\"">> dotfiles/.bash_aliases
