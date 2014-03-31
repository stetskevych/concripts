#!/bin/sh

echo 'this is not a runnable script, just notes'
exit 0

# local /etc/kde/env/ssh-agent-startup.sh and ~/.bashrc
# runs ssh-agent in only ONE copy per user
pgrep -u "$(whoami)" ssh-agent &>/dev/null || ssh-agent -s > ~/.ssh_agent_env
source ~/.ssh_agent_env >/dev/null

# remote .bashrc on jumpin for having screen there
if [ "$TERM" = "screen" ]; then
  . ~/.sshvars
else # plain ssh login
  for SSHVAR in SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY; do
    echo "export ${SSHVAR}=\"${!SSHVAR}\""
  done > ~/.sshvars
fi

# local .ssh/config for connecting through jumpin
Host git
Port 22                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                        
Host *                                                                                                                                                                                                                                                                  
ForwardAgent yes                                                                                                                                                                                                                                                        
Port 777                                                                                                                                                                                                                                                                
User user                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                        
Host jumpin
DynamicForward 1081                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                        
Host *.behind.jumpin
ProxyCommand /usr/bin/nc -x localhost:1081 %h %p
