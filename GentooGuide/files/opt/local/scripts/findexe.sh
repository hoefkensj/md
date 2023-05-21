#!/usr/bin/env bash
# ############################################################################
# # PATH: /opt/local/scripts                      AUTHOR: Hoefkens.j@gmail.com
# # FILE: findexe.sh
# ############################################################################
#
function findexe {
	local _ALL _FOUND
	function _genall {
		_ALL=$( compgen -A function -bcak )
		_ALL=$( printf "$_ALL" | sort | uniq )
	}
	function _filter {
		local filter resfiler subres
		subres="$_ALL"
		filter=".*?$1.*?"
		subres=$( printf "$subres" | grep -iE \'"$filter"\' )
		shift 1
		_FOUND="$subres"
		_filter $@
		
	}
	function _main {
		_genall
		_filter $@
		printf "_FOUND"
	}
	case "$1" in
		'') echo "$HELP" ;;
		-h|--help) 	echo "$HELP" ;;
		'-#'|--line)	shift 1 && _main $@ | sort  ;;
		-w|--wrap)	shift 1 && _main $@ | xargs -n 1  prinf " %s " ;; 
		-c|--column)	shift 1 && _main $@ | sort | column ;;
		-~|--fuzzy)	shift 1 && printf "$_ALL"| fzf -i ;;
		*) 		_main $@ ;;

	esac	
}
findexe $@
