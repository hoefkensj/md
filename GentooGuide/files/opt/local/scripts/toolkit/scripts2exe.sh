#!/usr/bin/env bash
#make binscripts

function scripts2exe (){
	function _slink() {
		for FILE in "${FILELIST[@]}" ; do
			DST=$( echo "${DSTROOT}/${FILE}")
			SRC=$( echo "${SRCROOT}/${FILE}")
			printf '%s < - < - < %s \n'  "${SRC}" "${DST}"
			ln -srvf $SRC "${DST%.sh}"
			sudo chmod +x "${DST%.sh}"
		done;
	}
	local SRCROOT DSTROOT DIRLIST FILELIST SRCDIR SRCROOT SRC DST
	SRCROOT=$( realpath "${1}/scripts/" )
	DSTROOT=$( realpath "${1}/bin" )
	FILELIST=($( find "$SRCROOT" -type f,l -iname '*.sh' -printf '%P\n'  ))
	_slink

}
scripts2exe "$@"