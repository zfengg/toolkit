# source the .bash_aliases_global e.g.
# source ~/Documents/GitHub/toolkit/dotfiles/.bash_aliases_global

# source the os specific bash scripts
if [[ `uname` = 'Linux' ]]
then
	source "$TOOLKIT/dotfiles/.bash_aliases_linux"
elif [[ `uname` = 'Darwin' ]]
then
	source "$TOOLKIT/dotfiles/.bash_aliases_macos"
else
	source "$TOOLKIT/dotfiles/.bash_aliases_win"
fi

# source the private script .bash_aliases_private if it exists
if [ -f ~/.bash_aliases_private ]; then
    . ~/.bash_aliases_private
    alias bashaliasprivate='vim ~/.bash_aliases_private'
fi
