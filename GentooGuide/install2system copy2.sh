#!/usr/bin/env bash
# ############################################################################
# # PATH: ./GentooGuide                           AUTHOR: Hoefkens.j@gmail.com
# # FILE: install2system.sh
# ############################################################################
#
# set -o errexit
# set -o xtrace
function merge2sys(){
	function _install() {		
		# for DIR in "${DIRLIST[@]}" ; do
		# 	DST=$( echo "${DSTROOT}${DIR}")
		# 	SRC=$( echo "${SRCROOT}/${DIR}")
		# 	printf './%s/* -> %s \n' "${SRC}" "${DST}"
		# 	install  -vD  "$SRC"/* "$DIR"
		for FILE in "${FILELIST[@]}" ; do
			DST=$( echo "${DSTROOT}/${FILE}")
			SRC=$( echo "${SRCROOT}/${FILE}")
			printf './%s/* -> %s \n' "${SRC}" "${DST}"
			install  -v  $SRC $DST
		done;
	}
	function _slink() {
		for FILE in "${FILELIST[@]}" ; do
			DST=$( echo "${DSTROOT}/${FILE}")
			SRC=$( echo "${SRCROOT}/${FILE}")
			printf '%s < - < - < %s \n'  "${SRC}" "${DST}"
			ln -svf $SRC $DST
		done;
	}

	local SRCROOT DSTROOT DIRLIST FILELIST SRCDIR SRCROOT SRC DST
	SRCROOT=$( realpath "$1" )
	DSTROOT=$( realpath "$2" )
	DIRLIST=($( find "$SRCROOT"  -type d -printf '%P\n' ))
	FILELIST=($( find "$SRCROOT"  -type f -printf '%P\n' ))
	_install "$@"
	echo '###################################################'
	# _slink "$@"

}
merge2sys $@
unset merge2sy