#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                          AUTHOR: Hoefkens.j@gmail.com
# # FILE: local.sh
# ############################################################################
#
# LOCAL Variables : required for loading the LOCAL(this system & system wide) bash (running-)config (rc)
_HOME='/opt/local';_CONFIG='config';_RC="rc"
export LOCAL="${_HOME}"
export LOCAL_CONFIG="${_HOME}/${_CONFIG}"
export LOCAL_CONFIG_RC="${_HOME}/${_CONFIG}/${_RC}"
export USER_CONFIG="${HOME}/.${_CONFIG}}"
export USER_CONFIG="${HOME}/.${_CONFIG}}/${_RC}"
# Check $PATH for /opt/bin , /opt/local/scripts/ and /opt/local/bin, if missing add, and export if needed
[[ ":$PATH:" != *":/opt/bin:"* ]]  && export PATH="/opt/bin:${PATH}"
[[ ":$PATH:" != *":/opt/local/bin:"* ]]  && export PATH="/opt/local/bin:${PATH}"
