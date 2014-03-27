#!/bin/sh
## This goes in /etc/kde/env/ssh-agent-startup.sh and ~/.bashrc
## Run ssh-agent in only ONE copy per user
pgrep -u "$(whoami)" ssh-agent &>/dev/null || ssh-agent -s > ~/.ssh_agent_env
source ~/.ssh_agent_env >/dev/null

# fix ssh agent forwarding on jumpin
if [ "$TERM" = "screen" ]; then
  . ~/.sshvars
else # plain ssh login
  for SSHVAR in SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY; do
    echo "export ${SSHVAR}=\"${!SSHVAR}\""
  done > ~/.sshvars
fi

