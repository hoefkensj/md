#/usr/bin/env bash
function tac_uniq_tac() {
	tac "$@" | awk '!seen[$0]++'  | tac
}
tac_uniq_tac "$@"
