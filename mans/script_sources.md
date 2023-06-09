```bash
#!/usr/bin/env bash
# ############################################################################
# # PATH: /opt/local/config/rc/bash               AUTHOR: Hoefkens.j@gmail.com
# # FILE: 311_history.conf
# ############################################################################
#
HISTFOLDER="/var/cache/bash/history"
HISTSIZE=-1
HISTFILESIZE="$HISTSIZE"
HISTCONTROL=''
HISTFILE="$HISTFOLDER/history.$$"
HISTSESSIONS="$HISTFOLDER/history.[0-9]*"
HISTGLOBAL="$HISTFOLDER/history.glob"
function _session_orphants {
	# detect leftover files from crashed sessions and merge them back
	local _active _pattern _orphaned
	_active=$(pgrep `ps -p $$ -o comm=`)
	_pattern=`for pid in $_active; do echo -n "-e \.${pid}\$ "; done`
	_orphaned=`ls $HISTSESSIONS 2>/dev/null | grep -v $_pattern`
	function _merge {
		echo Merging orphaned history files:
		for f in $_orphaned; do
			echo "  `basename $f`"
			cat $f >> $HISTGLOBAL
			\rm $f
		done
	}
	function _remove {
		for f in $_orphaned; do
			gio trash $f 2>/dev/null || rm -fv $f
		done
	}
	_remove
}
function _bash_history {
	builtin history -a "$HISTFILE"
	builtin history -a "$GLOBHIST"
	builtin history -c
	builtin history -r "$GLOBHIST"
	builtin history -r "$HISTFILE"
}
function history {
	_bash_history
	builtin history "$@"
}
_session_orphants
PROMPT_COMMAND=_bash_history

```

