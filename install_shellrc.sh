#!/usr/bin/env bash

SHELL=${1:-bash}

cp dotfiles/.${SHELL}rc ~
source ./install_bashaliases.sh

# for macos
if [[ $(uname) = 'Darwin' ]]; then
	echo "source ~/.bashrc" >> ~/.bash_profile
fi

