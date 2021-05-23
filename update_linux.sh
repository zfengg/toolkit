#!/usr/bin/env bash

# A simple shell script to automate the `copy' workflow in this Repo.

# bash
cp ~/.bashrc dotfiles/
cp ~/.bash_aliases dotfiles/

# vim
cp ~/.vimrc dotfiles/

# juliaSetup
cp ~/.julia/config/startup.jl julia_setup/
for i in {5..6}
do 
	mkdir -p julia_setup/v1.$i && cp ~/.julia/environments/v1.$i/* julia_setup/v1.$i/
done

# cp things to TA_Stuff
ext4cp='tex pdf'
mkdir -p TA_stuff/tex/solution
for extTmp in $ext4cp
do
	cp tex_templates/mysolution/*.$extTmp TA_stuff/tex/solution/TAsol.$extTmp
done
