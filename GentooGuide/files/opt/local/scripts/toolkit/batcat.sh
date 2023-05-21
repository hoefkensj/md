#!/usr/bin/env bash
# ############################################################################
# # PATH: /opt/local/scripts/toolkit              AUTHOR: Hoefkens.j@gmail.com
# # FILE: batcat.sh
# ############################################################################
#
# set -o errexit
# set -o nounset
function batcat ()
{
	local _cat _bat LANG STRING COLOR
	LANG="$1"
	shift 1
	STRING="$@"
	_cat=$( which "cat" )
	_bat=$( which "bat" )
	[[ -n "$_bat" ]] && printf '%s' "$@"  | $( printf '%s --%s --%s=%s' "$_bat" "plain" "language" "$LANG" ) 
	[[ -z $_bat ]] && echo $( printf '%s' "$@" ) | $( printf '%s' "$_cat"  ) 
};	
batcat "$@"