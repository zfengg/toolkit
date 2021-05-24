# set customized aliases here
# shortcuts
alias bashrc='vim ~/.bashrc'
alias bashalias='vim ~/.bash_aliases'
alias vimrc='vim ~/.vimrc'
alias mathfortune='fortune math | cowsay'

# easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cdgh='cd ~/Documents/GitHub/'
alias cdtoolkit="cd $PATHtoolkit"

# git
alias gadcm='git add -A && git commit -m'
alias gupignore='git rm -r --cached . ; git add . &&  git commit -m "update .gitignore"'

# some simple functions
mks() {
	# make a runnable script
	if [ ! -f $1 ]; then
		echo "#!/usr/bin/env ${2:-bash}" > $1
		chmod 755 $1
	else
		echo "$1 already exists!"
	fi
}

datename() {
	# attach date to the name of a file as a copy
	cp $1 "${2:-$(dirname $1)}/$(date -I)_$(basename $1)"
}

extname() {
	# get the extension of a filename
	basename $1 | sed 's/.*\.\(.*\)/\1/'
}

barename() {
	# get the bare name of a filename
	basename $1 | sed 's/\(.*\)\..*/\1/'
}

## julia installing workflow
jlinstall() {
	local PATH_DOWNLOAD="$HOME/Downloads"
	local PATH_USRBIN="/usr/local/bin"
	local DIR_INSTALL="/opt"
	local tarball="julia-$1-linux-x86_64.tar.gz"
	local linkDownload="https://julialang-s3.julialang.org/bin/linux/x64/${1:0:3}/$tarball"

	echo "downloading the julia tar-ball:"
	wget --directory-prefix $PATH_DOWNLOAD $linkDownload
	echo ":) download finished!"

	echo ">>> unpacking tarball to $DIR_INSTALL :"
	sudo tar -xvzf "$PATH_DOWNLOAD/$tarball" --directory=$DIR_INSTALL
	echo ":) julia tarball unpacked at $DIR_INSTALL/julia-$1/ !"

	echo "creating symbolic link"
	sudo ln -s "$DIR_INSTALL/julia-$1/bin/julia" "$PATH_USRBIN/julia$1"
	# replace the default julia command
	if [ -n "$2" ]; then
		sudo rm "$PATH_USRBIN/$2"
		sudo ln -s "$DIR_INSTALL/julia-$1/bin/julia" "$PATH_USRBIN/$2"
	fi
	echo ":) symbolic links created!"

	echo "removing the downloaded tarball"
	rm "$PATH_DOWNLOAD/$tarball"
	echo ":) tarball removed!"

	if [ -n "$2" ]; then
		echo ":) All finished!!! Please check by running: julia$1 or $2 "
	else
		echo ":) All finished!!! Please check by running: julia$1 "
	fi
}

jluninstall() {
	local PATH_USRBIN="/usr/local/bin"
	local DIR_INSTALL="/opt"

	sudo rm -rf "$DIR_INSTALL/julia-$1"
	echo "installation dir: $DIR_INSTALL/julia-$1 removed!"

	sudo rm "$PATH_USRBIN/julia$1"
	echo "symbolic link: $PATH_USRBIN/julia$1 removed!"
}

jlsetbin() {
	local PATH_USRBIN="/usr/local/bin"
	local DIR_INSTALL="/opt"

	sudo rm "$PATH_USRBIN/julia"
	sudo ln -s "$DIR_INSTALL/julia-$1/bin/julia" "$PATH_USRBIN/julia"

	echo "Please check by running: julia"
}

## latex
texindent() {
	# autoindent .tex files
	 find $1 -name '*.tex' -exec latexindent -w -s {} \;
}

texrmbak() {
	# remove *.bak* files
	find $1 -name '*.bak*' -exec rm {} \;
}

export PATHtoolkit="$HOME/Documents/GitHub/toolkit"
mkmytex() {
	# create a .tex from myarticle.tex
	local default3=`pwd`
	local default2=`basename $default3`
	local ext4cp='tex bib'
	for extTmp in $ext4cp
	do
		if [[ -f "$PATHtoolkit/tex/my$1/my$1.$extTmp" ]]; then
			cp $PATHtoolkit/tex/my$1/my$1.$extTmp ${3:-$default3}/$default2.$extTmp
		fi
	done
}

# export the path to repo: toolkit
export PATHtoolkit=$(dirname `pwd`)
