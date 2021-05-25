#!/usr/bin/env bash

# A simple shell script to automate the `copy' workflow in this Repo.

# bash
cp ~/.bashrc dotfiles/
cp ~/.bash_aliases dotfiles/

# vim
cp ~/.vimrc dotfiles/

# juliaSetup
cp ~/.julia/config/startup.jl julia/
for i in {5..6}
do 
	mkdir -p julia/v1.$i && cp ~/.julia/environments/v1.$i/* julia/v1.$i/
done

# cp things to TA_Stuff
ext4cp='tex pdf'
mkdir -p TA/tex/solution
for extTmp in $ext4cp
do
	cp tex/mysolution/mysolution.$extTmp TA/tex/solution/TAsol.$extTmp
done

# add path to this repo to .bash_aliaes
echo  >> dotfiles/.bash_aliases
echo "# export the path to repo: toolkit" >> dotfiles/.bash_aliases
echo "export PATHtoolkit=\$(dirname \`pwd\`)" >> dotfiles/.bash_aliases
echo "alias cdtoolkit=\"cd \$PATHtoolkit\"">> dotfiles/.bash_aliases
