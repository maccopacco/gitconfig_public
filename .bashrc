# Load aliases
if [ -e $HOME/.bash_aliases ]; then
	source $HOME/.bash_aliases
fi

################################################################################
# Program aliases 
alias g='git'
alias rg='"C:/Program Files (x86)/FANUC/ROBOGUIDE/bin/ROBOGUIDE.exe"'

alias new='start "" "C:\Program Files\Git\git-bash.exe"'
alias nx='new && exit'

alias pn='plcncli generate all && plcncli build && plcncli deploy'

alias see='cd "c:/Users/Public/Documents/IGE+XAO/SEE Electrical/V8R3"'

################################################################################
# SEE Electrical start
alias ses='ls | grep ".sep" | xargs start' 
alias sas='ls | grep ".*autogen.*.xlsx" | xargs start'

# CLICK start
alias cls='ls | grep ".ckp" | xargs start'
# C-More start
alias cms='ls | grep ".eap9" | xargs start'

# AB Start
alias sfs='ls | grep -i ".ACD" | grep -v "BAK" | xargs start'

# ROBOGUIDE start
alias rgs='ls content | grep ".frw" | xargs -I {} sh -c "start content/{}"'

################################################################################
# Start this
alias brcs='vim $HOME/.bashrc'
alias gce='vim $HOME/.gitconfig'
alias src='source $HOME/.bashrc'
alias doc='cd $HOME/Documents'
alias home='cd $HOME'

alias woff='start $HOME/woff.lnk'
alias won='start $HOME/won.lnk'

################################################################################
# JMC SharePoint Git Directories
CGIT="$HOME/JMC Industries/JMC Controls Team - Documents"
RGIT="$CGIT/Roboguide_Git"
EGIT="$CGIT/Electrical_Git"
EPATH="$HOME/JMC Industries/Engineering - Documents"
alias po="cd '$EPATH/Purchase Orders'"

################################################################################



# Personal Excel File directory/name
EXL_FILE="PERSONAL.xlsb"
EXL_DIR="$HOME/AppData/Roaming/MicroSoft/Excel/XLSTART/$EXL_FILE"

declare -A repos=(["m"]="maccopacco" ["j"]="jmc-industries")

################################################################################
function sfw {
	if [ "$(tasklist | grep -i "LogixDesigner.exe")" != "" ] 
	then
		echo "Waiting on Studio 5000 to die"
	fi
	while [ "$(tasklist | grep -i "LogixDesigner.exe")" != "" ] 
	do
		sleep 1
	done
}

# Kill excel
function ke {
	cmd //c "taskkill /f /im excel.exe"
}

# Silent print
# https://unix.stackexchange.com/questions/53085/print-tee-to-console-without-passing-output-to-pipe
function sp { echo "$@" >&2; cat -; }

# Git search
function gs {
	GS=$(git lg | grep -P "$1" | head -n 1 | grep -oE " [A-Za-z0-9]{7} " | grep -oE "[A-Za-z0-9]{7}" | head -n 1)
	echo "$GS" | sp "$(git show -s $GS --pretty=format:'%s (%h)')"
}

# Update origin
function updo {
	PTH=$(basename $PWD)
	EL=$(echo "$PTH" | grep -oE ".*-e$")
	RG="$(echo "$PTH" | grep -oE ".*-rg$")"
	if [ -n "$EL" ]; then
		echo "Identified as Electrical git"
		git remote remove origin
		git remote add origin "$EGIT/$PTH"
	elif [ -n "$RG" ]; then
		echo "Identified as Roboguide git"
		git remote remove origin
		git remote add origin "$RGIT/$PTH"
	else
		echo "Not identified"
	fi
}


# XML formatter
function xmlf {
	xmllint --format $1
}

# Self explanatory
function beep {
	echo -ne "\a"
}

# Update submodule based on git diff
function git_updsm {
	MOD=$(cat .gitmodules | grep "path" | sed "s/\spath =\s//")
	COMMIT=$(git diff | grep "\-.*commit.*" | sed -E "s/.*commit\s//") 
	echo $MOD
	echo $COMMIT
	cd $MOD
	git co $COMMIT
	cd -
}

# Setup GH CLI
function power_toys { 
	cmd.exe /c "winget install -e --id Microsoft.PowerToys"
}

# Smarter GH Clone
function ghc {
	if [ $# -ne 2 ]
	then
		echo "Must enter value from repo map and dir"
		return
	else
		REPO=${repos[$1]}
	fi

	if [ -z "$REPO" ]
	then
		echo "Invalid repo"
		return
	fi

	C="https://github.com/$REPO/$2"
	echo "Cloning $C"
	git cl "$C"
	cd $2
}

# GH Init
function ghinit {
	if [ $# -lt 1 ]
	then
		echo "Must enter value from repo map and dir(optional)"
		return
	else
		REPO=${repos[$1]}
	fi

	if [ -z "$REPO" ]
	then
		echo "Invalid repo"
		return
	fi

	DontMakeDir=0 
	Dir=$2
	if [ $# -lt 2 ] 
	then
		read -n 1 -p "Make the directory here? It'll do everything here??? (y/n): " Confirm
		echo ""
		if [ $Confirm != 'y' ]
		then
			echo "Your bad. Quitting"
			return
		fi
		DontMakeDir=1
		Dir="$(basename $PWD)"
	fi

	if ! (($DontMakeDir))  
	then	
		mkdir $Dir || return
		cd $Dir
	fi

	origin="https://www.github.com/$REPO/$Dir"
	echo "Creating repo at $origin"


	if ! [ -d .git/ ] 
	then
		echo "ghinit initializing git repo"
		git init
	fi

	gh repo create "$REPO/$Dir" --private
	git remote remove origin || echo "No origin found, that's fine"
	git remote add origin "$origin"
	echo "Origin added"
}

# Find previous command matching regex and ask to execute it
function prev {
	CMD="$(history | grep -v -E "^\s+[0-9]+\s+prev" | sed -E "s/^\s+[0-9]+\s+//"  | grep -E "$1" | tail -n -1)"

	if [ -z "$CMD" ]
	then
		echo "No command found"
		return
	fi

	read -n 1 -p "[$CMD] look good? (Run=r/y, copy=c): " Confirm
	echo
	if [ "$Confirm" == 'r' ] || [ "$Confirm" == 'y' ]
	then 
		eval "$CMD"
	elif [ "$Confirm" == 'c' ]
	then
		echo $CMD | clip
	fi
}

# Setup GH CLI
function setup_gh { 
	cmd.exe /c "winget install --id GitHub.cli"
}	


# Pull Excel file
function pull_ex {
	cp $EXL_DIR $HOME
	echo "Pulled"
}

# Push Excel file
function push_ex {
	cp "$HOME/$EXL_FILE" $EXL_DIR
	echo "Pushed"
}

# Robooguide zip
function rgz {
	rgw
	echo "Zipping RG"
	rm content.zip
	"C:\Program Files\7-Zip\7z.exe" a content.zip content/
}

# Roboguide unzip
function rguz {
	rgw
	echo "Unzipping RG"
	rm content -rf
	"C:\Program Files\7-Zip\7z.exe" x content.zip
}


# Roboguide wait to be done
function rgw {
	if [ "$(tasklist | grep "RGCore.exe")" != "" ] 
	then
		echo "Waiting on RG to die"
	fi
	while [ "$(tasklist | grep "RGCore.exe")" != "" ] 
	do
		sleep 1
	done
}

# Roboguide zip and start
function rgzs {
	rgz
	rgs
}

# Roboguide unzip and start
function rguzs {
	rguz
	rgs
}

# Fix Git issue
function fix_unpacker {
	git fsck
	git prune
	git repack
	git fsck
}

# Roboguide set origin (ignore errors)
function rggitset {
	git remote show origin || true 
	git remote remove origin || true
	git remote add origin "$RGIT/$(basename $(pwd))"
}

# Open Github repo
function gbrowse {
	gb=$(git config --get remote.origin.url)
	printf "URL of origin: [$gb]"
	start $gb
}

# Open Github repo issues
function gissue {
	gi="$(git config --get remote.origin.url)/issues"
	printf "$gi"
	start $gi
}

# Wolfram equation
function wc {
	RESP="$(wa "$1")"
	echo "$1 = $RESP"
}

# Wolfram
function wl {
	WAID="SET YOUR OWN ID"
	WAFG="transparent"
	WABG="white"

	curl -s "https://api.wolframalpha.com/v1/simple?appid=$WAID&units=imperial&foreground=$WAFG&background=$WABG" --data-urlencode "i=$1" | magick - win:
}

# Wolfram Short
function ws {
	WAID="SET YOUR OWN ID"
	WAFG="transparent"
	WABG="white"

	RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$WAID&units=imperial&" --data-urlencode "i=$1")
	echo "$RESPONSE"
}

# Wolfram alpha generic
function wa {
	WAID="SET YOUR OWN ID"
	WAFG="transparent"
	WABG="white"

	RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$WAID&units=imperial&" --data-urlencode "i=$1")
	BAD="No short answer available" 
	if [ "$RESPONSE" = "$BAD" ]
	then
		echo -e "$RESPONSE, downloading full answer..." 
		$(wl "$1")
	else
		echo "$RESPONSE"
	fi
}

export -f wl
export -f wa
export -f ws
export -f gs
export -f sp
