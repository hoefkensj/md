#!/bin/bash
function fn() {
	local HELP FV 
	HELP="
${FUNCNAME[0]} [-h|--help] [-qvd] [args]
ARGUMENTS:
    [arg]          description

OPTIONS:
  -h  --help     Show this help text
  -q  --quiet    Dont produce any output
  -v  --verbose  For compatibility only
  -d  --debug    Enable Debugging

EXAMPLES :

";
    set -o errexit
	# set -o nounset
    function _main ()
    {
        echo main;
	};

	case "$1" in
		--	| -	| ''	)	sh "$LOCAL_TOOLKIT/batcat.sh" help "$HELP"	;;
		--help 		| -h)	sh "$LOCAL_TOOLKIT/batcat.sh" help "$HELP"	;;
		--quiet		| -q)	shift 1 && ${FUNCNAME[0]} "$@" &> /dev/null	;;
		--verbose	| -v)	shift 1 && FV='YES' && ${FUNCNAME[0]} "$@" 		;;
		--debug		| -d)	shift 1 && set -o xtrace &&  ${FUNCNAME[0]}  "$@" ;;
		*)	_main "$@" ;;
	esac;
	unset _main
	};

fn "$@"