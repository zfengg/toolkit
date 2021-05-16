# set customized aliases here
# shortcuts
alias cdgh='cd ~/Documents/GitHub/'
alias gadcm='git add -A && git commit -m'
alias bashrc='vim ~/.bashrc'
alias bashalias='vim ~/.bash_aliases'

# easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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
