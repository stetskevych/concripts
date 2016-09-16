#!/bin/bash
# backup locally and encrypt

set -e

if [[ "$(id -u)" != 0 ]]; then
  echo "You have to be root."
  exit 1
fi

USER='vst'
DATE="$(date +%Y%m%d)"
DIR="/home/$USER/backup/$DATE"

dotfiles=(.bash_history .bash_logout .bash_profile .bashrc .screenrc .config .fontconfig .fonts .gnupg .kde .kde4 .ssh .aws .Skype)

[[ ! -d "$DIR" ]] && mkdir -p $DIR

read -p "Have you deleted Chrome cache? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

read -s -p "GPG Passphrase: " PASS

yes | pacman -Sc
journalctl --vacuum-size=100M

[[ ! -p backup ]] && mkfifo backup
exec 3<>backup

echo "$PASS" >&3
tar -cvf - -C /boot --numeric-owner --preserve-permissions --one-file-system /boot | pigz -9 | gpg -c --batch --no-tty --yes --passphrase-fd 3 -o $DIR/arch-boot-${DATE}.tar.gz.gpg
echo "$PASS" >&3
tar -cvf - -C /home/"$USER" --numeric-owner --preserve-permissions --one-file-system "${dotfiles[@]}" | pigz -9 | gpg -c --batch --no-tty --yes --passphrase-fd 3 -o $DIR/arch-dotfiles-${DATE}.tar.gz.gpg
echo "$PASS" >&3
tar -cvf - -C / --numeric-owner --preserve-permissions --one-file-system / | pigz -9 | gpg -c --batch --no-tty --yes --passphrase-fd 3 -o $DIR/arch-root-${DATE}.tar.gz.gpg

chown -R "$USER":users "$DIR"

unset PASS

echo "done"
