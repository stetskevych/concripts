#!/bin/bash
# backup from one laptop to another

set -e

if [[ "$(id -u)" != 0 ]]; then
  echo "You have to be root."
  exit 1
fi

HOST='192.168.168.2'
USER='slava'
DATE="$(date +%Y%m%d)"
DIR="/home/$USER/backup/$DATE/"
RSH='ssh -p22 -o Cipher=arcfour'
CREDS="$USER@$HOST"

dotfiles=(.bash_history .bash_logout .bash_profile .bashrc .config .fontconfig .fonts .gnupg .kde .kde4 .ssh .aws .Skype)

yes | pacman -Sc
journalctl --vacuum-size=100M

ssh "$CREDS" "mkdir $DIR"

#cd /home/"$USER"
#rsync -aHAP --rsh="$RSH" "${dotfiles[@]}" "$CREDS:$DIR"
#cd -

tar -cvzf - -C /home/"$USER" --numeric-owner --preserve-permissions --one-file-system "${dotfiles[@]}" | $RSH "$CREDS" "cat > $DIR/arch-dotfiles-${DATE}.tar.gz"
tar -cvzf - -C / --numeric-owner --preserve-permissions --one-file-system / | $RSH "$CREDS" "cat > $DIR/arch-root-${DATE}.tar.gz"
tar -cvzf - -C /boot --numeric-owner --preserve-permissions --one-file-system /boot | $RSH "$CREDS" "cat > $DIR/arch-boot-${DATE}.tar.gz"
