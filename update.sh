#!/usr/env bash

# A simple shell script to automate the `copy' workflow in this Repo.

# bash
cp ~/.bashrc dotfiles/
cp ~/.bash_aliases dotfiles/

# vim
cp ~/.vimrc dotfiles/

# juliaSetup
cp ~/.julia/config/startup.jl juliaSetup/
for i in {5..6}
do 
  cp ~/.julia/environments/v1.$i/* juliaSetup/v1.$i/
done
# cp ~/.julia/environments/v1.6/* juliaSetup/v1.6/
