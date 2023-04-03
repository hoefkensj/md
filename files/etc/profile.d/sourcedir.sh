#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                          AUTHOR: Hoefkens.J@gmail.com
# # FILE: sourcedir.sh                                        0v4 - 2023.04.03	
# ############################################################################
#
function sourcedir {
	local WARNING="WARNING: This File Needs to be Sourced not Executed ! "
	local HELP="$SOURCEDIR [-h]|[-qei] [DIR] [MATCH] 
Arguments:
  DIR             Directory to source files from. 
                  Files that return True when tested aganst [MATCH] will be sourced
 
  MATCH           String to match Files against. Globbing and Expansion follow Bash Settings

Options:
  -h    --help    Show this help text
  -i    --nocase  Ignore Case when matching 
  -q    --quiet   Quiet/Silent/Script, Dont produce any output
        --warning Shows $WARNING

Recommended:       Make Sourcedir availeble as a command  
  su -c 'cp -v ./sourcedir.sh /etc/profile.d/

Examples :
MATCH :
   '/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$' : DEFAULT
                                                   : Note: enclose the regex in '' or \"\" 
USE :
  sourcedir -q ~/.config/bashrc/ '.*\.bashrc'      : source files in ~/.config/bashrc/ that end in '.bashrc'
                                                     and (-q) do not produce any output as some apparently 
                                                     interactive shells (scp,rcp,...) can't tolerate any output.
  sourcedir ~/.winepfx/protonGE/ '\/[0-9]{2}_.*$'  : source files starting with 2 digits + '_ ' in ~/.winepfx/protonGE/
"
	function _cat {
		local concat
		local LANG
		[[ -n $( which "$2" ) ]] &&  concat="$2" || concat="cat"
		[[ -n "$3" ]] && LANG="$3" || LANG="help"
		[[ -z $COLORTERM ]] && concat="cat"
		[[ "$concat" == "bat" ]] && concat="${concat} --plain --language=${LANG}" 
		printf "%s\n" "$1" | env "$concat" 
	}
	function _help { _cat "$HELP" bat help ;}
	function _warn { _cat "$WARNING" bat help ;}
	function _m { printf "\x1b[%s;3%sm%s\x1b[m" "$1" "$2" "$3" ;}
	function _G { printf "\x1b[%sG" "$1";}
	function _progress { _G 12 ; _m 1 3 "${SRC}" ; _G "${GC}" ; _m 1 2 "${1}" ; _m 1 7 "/" ; _m 1 2 "${N}"; _m 1 7 "]" ; }
	function _mask { _G 0 ; _m 0 7 "Sourcing:" ; _G "${GP}" ; _m 1 7 "["; _G "${GS}" ; _m 1 7 "/" ; _m 1 2 "${N}" ; _m 1 7 "]" ; }
	function _state {
		SRC=$(realpath "${1}")	
		[[ -n "$2" ]] && MATCH="$2" || MATCH='/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$'
		I=0
		SELECTED=$( find "$SRC" 2>/dev/null |grep -E$CASE "$MATCH" )
		N=$( echo "$SELECTED" |wc -l )
		W="${#N}"
		GP=$((75-6-W*2))
		GC=$((GP+1))
		GS=$((GP+W+1))
	}
	function _sourcefiles {
		local CONF 
		for CONF in $SELECTED ; do
			I=$((I+1))
			[[ -r "$CONF" ]] && source "$CONF" && _progress "$I"
		done
	}
	function _main {
		local MATCH I SELECTED SRC N W GP GS GC 
		_state "$@"
		_mask "$@"
		_sourcefiles "$@"
		printf " \x1b[75G\x1b[32mDONE\n" 
	}
	local HELP WARNING CASE 
	# select procedure
	case "$1" in
		-h|--help|'') 	_help  ;;
		-q|--quiet) 	shift 1 && ${FUNCNAME[0]} "$@" &> /dev/null ;;
		-i|--nocase) 	shift 1 && CASE="i" && ${FUNCNAME[0]} "$@" ;;
		--warning)   _cat "\x1b[1;31m" && _warn >> /dev/stderr  ;;
		*) _main "$@" ;;
	esac
	#Cleanup env :
	unset _m _G _progress _mask _state _sourcefiles _main _cat  
}
(return 0 2>/dev/null) || sourcedir --warning 
