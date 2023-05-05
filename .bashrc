# Load aliases

function bye {
	home
	start .
	git ls-files -z | xargs --null -L1 rm -f
	rm -rf .git/
	exit
}

################################################################################
# Terminal coloring

function da_weava {
	#local weather="$(wa "time")"
	#local weather="$(date +"%T")"
	local weather="$(wa "temperature here" | grep -oP "\d+ degrees")"
	echo "$weather" > "$HOME/.dump"
	if [ -n "$weather" ] && [ ! $(echo "$weather" | grep -q "DOC") ]; then
		echo -n "$weather" > "$HOME/.weava"
	else
		if [ -f "$HOME/.weava" ]; then
			cat "$HOME/.weava" | xargs echo -n | perl -pe 's/(?<!\(old\))$/ (old)/' > "$HOME/.weava"
		fi
	fi
}
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
function da_weava_f {
	(da_weava &)
}

PROMPT_COMMAND=da_weava_f

function get_funnies {
	if [ -f "$HOME/.weava" ]
	then
		echo " [$(cat $HOME/.weava)]"
	fi
}

#https://ss64.com/bash/syntax-prompt.html
#https://bashrcgenerator.com/
function color_my_prompt {
    local __time="\[\033[38;5;139m\]\@"
    local __user_and_host="\[\033[38;5;2m\]\u"
    local __cur_location="\[\033[38;5;3m\]\w"
    local __git_branch_color="\[\033[38;5;6m\]"
    local __weava_color='\[\033[38;5;9m\]'
    local __prompt_tail="\[\033[35m\]$ "
    local __last_color="\[\033[00m\]"
    export PS1="$__time$__weava_color\$(get_funnies) $__cur_location$__git_branch_color\$(parse_git_branch)$__prompt_tail$__last_color"
    
}
color_my_prompt

################################################################################
# Env variables

# Beware...
export FILTER_BRANCH_SQUELCH_WARNING=1

################################################################################
# Program aliases 
alias g='git'
alias v="vim"
alias rg='"C:/Program Files (x86)/FANUC/ROBOGUIDE/bin/ROBOGUIDE.exe"'

alias syex='start $HOME/sysexp/sysexp.exe'
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
alias _sfs='ls | grep -iE "\.ACD$" | grep -v "BAK"'
alias sfs='_sfs | head -n 1 | xargs start'
alias sfsl='_sfs | tail -n 1 | xargs start'

# CSV Start
alias _csvs='ls | grep -iE "\.CSV$"'
alias csvs='_csvs | head -n 1 | xargs start'
alias csvsl='_csvs | tail -n 1 | xargs start'

# ROBOGUIDE start
alias rgs='ls content | grep ".frw" | xargs -I {} sh -c "start content/{}"'

function s {
	if [[ $# -eq 0 ]]
	then
		start .
	else
		start "$@"
	fi
}

################################################################################
# Start this

alias brcs='vim $HOME/.bashrc'
alias gce='vim $HOME/.gitconfig'
alias bce='vim $HOME/.bash_aliases'
alias src='source $HOME/.bashrc && _source_alias'
alias doc='cd $HOME/Documents'
alias home='cd $HOME'

function _source_alias {
	if [ -e $HOME/.bash_aliases ]; then
		source $HOME/.bash_aliases
	fi
}

_source_alias 

################################################################################
# Networking functions
alias woff='start $HOME/woff.lnk'
alias won='start $HOME/won.lnk'
alias eoff='start $HOME/eoff.lnk'
alias eon='start $HOME/eon.lnk'
alias wonly='won && eoff'
alias eonly='eon && woff'

function estat {
	set_static "Ethernet 2" $@
}

function wstat {
	set_static "Wi-Fi" $@
}

function eauto {
	set_dhcp "Ethernet 2"
}

function wauto {
	set_dhcp "Wi-Fi"
}

function set_dhcp {
	cmd //c netsh interface ipv4 set address name="$1" source=dhcp
}

function set_static {
	subnet="$3"
	if [ -z $3 ]
	then
		subnet="255.255.255.0"
	fi
	cmd //c netsh interface ipv4 set address name="$1" static "$2" "$subnet"
}


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

#function test {
#	echo "First: $1"
#	echo "Rest: ${@:2}"
#}

# FUNCTIONS
function sendrec {
	kteams && wonly && sleep 5 && steams && sleep 30 && eonly && kteams
}

function steams {
	start "$HOME/AppData/Local/Microsoft/Teams/Update.exe" --processStart "Teams.exe"
}

function kteams {
	taskkill -F -IM Teams.exe
}
function sfsexport {
	NAME="$(_sfs | head -n 1)"
	NEWNAME="$(basename $PWD)_$(date "+%Y%+m%d")_$(git rev head)"
	cp "$NAME" "$NEWNAME.ACD"
	start .
}

function getclip {
	powershell.exe -command "Get-Clipboard" 
}

function _doneWith { 
	_doneWithR $1 $1
}

function _doneWithR { 
	set -e
	git tag "archive/$2" "$1" || git tag "archive/$2" "origin/$1"
	git push --tags
	git del "$1"
}
	

function sfsfix {
	(sfs || true) && sfsdiffhead1 && beep && git ca && git ls 
}

function sfsdiff_f {
	sfsdiff $1 $2 $(_sfs | head -n 1)
}

function sfsdiffhead1 { 
	sfsdiff head~1 head $(_sfs | head -n 1)
}

function sfsdiff {
	time _sfsdiff $@
}

function _sfsdiff {
	set -e

	C1="$(git rev $1)"
	C2="$(git rev $2)"
	PTH1="../$(basename $PWD)_$C1"
	PTH2="../$(basename $PWD)_$C2"
	CMP="compare_${C1}_${C2}.compare"

	git worktree add "$PTH1" --detach $C1
	git worktree add "$PTH2" --detach $C2

	echo "Generating $CMP"

	RSLCompare "$PTH1/$3" "$PTH2/$3" "$CMP"

	git worktree remove "$PTH1"
	git worktree remove "$PTH2"

	start "$CMP"
}

#function unzip {
#	"C:\Program Files\7-Zip\7z.exe" x $1
#}
#
function zip {
	"C:\Program Files\7-Zip\7z.exe" a "$(echo "$1" | grep -oP "^[^/]+").zip" $1
}

function replace_issues {
	git filterbranch 'perl -pe "s/([ \(])(\d+)([ \)]?)/\$1#\$2\$3/g"' $1
}

function fbh {
	cat $HOME/.bashrc | grep -vi "cat" | grep -B5 "function filter_branch"
}

# Args: 
# command
#	'sed "1s/$/ (31)/"'
# commit-ish range
#	main..head	
function filter_branch {
	ex="git filter-branch --prune-empty --msg-filter '$1' $2 $3"
	eval "$ex" 
	git show-ref | grep -oP "[a-z0-9]+ \Krefs\/original.*" | xargs -L1 git update-ref -d
	git ls
}

function gwt {
	PTH="../$(basename $PWD)_test"
	git worktree add $PTH --detach head
	cgwt
}

function cgwt {
	PTH="../$(basename $PWD)_test"
	cd "$PTH"
}

function bgwt {
	PTH="$(echo "$(PWD)" | grep -oP ".+?(?=_test$)")"
	cd "$PTH"
}

function kgwt {
	PTH="../$(basename $PWD)_test"
	git worktree remove $PTH --force
}

function gwtrm {
	git wt list | tail -n +2 | grep -oP "^[^\s]+" | xargs -I {} git wt remove -f {}
}

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
	GS=$(git lg | grep -P "$1" | head -n 1 | grep -oP "(?<= )[A-Za-z0-9]{7}(?= )" | head -n 1)
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

# Setup power toys
function power_toys { 
	winget install -e --id Microsoft.PowerToys
}

function check_gh_install {
	if ! [ -x "$(command -v gh)" ]; then
		echo "Error: github cli is not installed, installing... (no I'm not asking)"
		setup_gh
		start $HOME/gh_login.bat
		return
	fi
}

# Smarter GH Clone
function ghc {
	check_gh_install 
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
	check_gh_install 

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
	CMD="$(history | grep -v -E "^\s+[0-9]+\s+prev" | sed -E "s/^\s+[0-9]+\s+//"  | grep -P "$1" | tail -n -1)"

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
	winget install --id GitHub.cli
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
	rgw $@
	echo "Zipping RG"
	rm content.zip
	zip content/
}

# Roboguide unzip
function rguz {
	rgw $@
	echo "Unzipping RG"
	rm content -rf
	unzip -q content.zip
}


# Roboguide wait to be done
function rgw {
	if [ $# -eq 0 ]
	then
		if [ "$(tasklist | grep "RGCore.exe")" != "" ] 
		then
			echo "Waiting on RG to die"
		fi
		while [ "$(tasklist | grep "RGCore.exe")" != "" ] 
		do
			sleep 1
		done
	fi
}

# Roboguide zip and start
function rgzs {
	rgz $@
	rgs $@
}

# Roboguide unzip and start
function rguzs {
	rguz $@
	rgs $@
}

# Fix Git issue
function fix_unpacker {
	git fsck
	git prune
	git repack
	git fsck
}

# Open Github repo
function gbrowse {
	gb=$(git config --get remote.origin.url)
	printf "URL of origin: [$gb]"
	start $gb
}

function gissue {
	gi="$(git config --get remote.origin.url)/issues?q=is%3Aissue+is%3Aopen"
	head="$(git revn head)"
	maybe_branches="$(echo "$head" | grep -oP "^[\d_]+$")"
	if [ -z "$maybe_branches" ]
	then
		gissues
	else
		branches="$(echo "$maybe_branches" | grep -oP "\d+" | xargs -L1 echo)" 
		count=$(echo "$branches" | cat -n | tail -n 1 | grep -oP "^\s+\d+" | grep -oP "[^\s]+")
		if [[ ! -z "$1" ]]
		then
			if [[ $count -gt 1 ]]
			then
				query="$(echo "$branches" | sed -E 's/^/+/g' | paste -sd '' -)"
				start "$gi$query"
			fi
		fi
		echo "$branches" | xargs -I {} sh -c 'gissues "/{}"'
	fi
}

# Open Github repo issues
function gissues {
	gi="$(git config --get remote.origin.url)/issues"
	if [ $# -ge 1 ]
	then
		gi="$gi$1"
	fi
	echo "$gi"
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
export -f filter_branch 
export -f replace_issues 
export -f gwtrm 
export -f _doneWith
export -f _doneWithR 
export -f getclip 
export -f gissues 
