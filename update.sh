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
  cp ~/.julia/environments/v1.$i/* julia_setup/v1.$i/
done
