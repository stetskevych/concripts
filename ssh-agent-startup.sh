#!/bin/sh
## This goes in /etc/kde/env/ssh-agent-startup.sh and ~/.bashrc
## Run ssh-agent in only ONE copy per user
pgrep -u "$(whoami)" ssh-agent &>/dev/null || ssh-agent -s > ~/.ssh_agent_env
source ~/.ssh_agent_env >/dev/null

