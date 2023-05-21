#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                          AUTHOR: Hoefkens.j@gmail.com
# # FILE: local.sh
# ############################################################################
#
## LOCAL VARS
export LOCAL_HOME="/opt/local"
export LOCAL_CONFIG="${LOCAL_HOME}/config"
export LOCAL_RC="${LOCAL_CONFIG}/rc"
export LOCAL_BIN="${LOCAL_HOME}/bin"
export LOCAL_CACHE="${LOCAL_HOME}/cache"
export LOCAL_SCRIPTS="${LOCAL_HOME}/scripts"
export LOCAL_TOOLKIT="${LOCAL_SCRIPTS}/toolkit"
## USER VARS
export USER_CONFIG="${HOME}/.config"
export USER_RC="${USER_CONFIG}/rc"
export USER_BIN="${HOME}/.bin"
export USER_CACHE="${HOME}/.cache"

## COMPILERS
### ZIG

PATHARR=($(tr ':' '\n' <<< "$PATH"))
[[ ":${PATH}:" != *":${HOME}/Development/Compilers/zig/:"* ]]  && PATHARR=("${HOME}/Development/Compilers/zig/" "${PATH[@]}")
[[ ":${PATH}:" != *":/opt/bin:"* ]]  && PATHARR=("/opt/bin" "${PATH[@]}")
[[ ":${PATH}:" != *":${LOCAL_BIN}:"* ]]  && PATHARR=("${LOCAL_BIN}" "${PATH[@]}")
[[ ":${PATH}:" != *":${USER_BIN}:"* ]]  && PATHARR=("${USER_BIN}" "${PATH[@]}")
export PATH=$( tr ' ' ':' <<< "${PATHARR[@]}")

unset PATHARR
