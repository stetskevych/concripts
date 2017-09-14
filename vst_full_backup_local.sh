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
COMPRESSOR='pigz -9'
COMPRESSEXT='gz'
#COMPRESSOR='xz -c -z - --threads=0'
#COMPRESSEXT='xz'

dotfiles=(.bash_history .bash_logout .bash_profile .bashrc .screenrc .config .gnupg .kde4 .ssh .aws)
excludes="--exclude swapfile* --exclude var/cache/pacman/pkg/*"

[[ ! -d "$DIR" ]] && mkdir -p $DIR

read -p "Have you deleted Chrome cache? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

read -s -p "GPG Passphrase: " PASS

yes | pacman -Sc
journalctl --vacuum-size=50M

[[ ! -p backup.fifo ]] && mkfifo backup.fifo
exec 3<>backup.fifo

set -euo pipefail

echo "$PASS" >&3
tar $excludes -cvf - -C / --numeric-owner --preserve-permissions --one-file-system / | $COMPRESSOR | gpg -c --cipher-algo AES256 --batch --no-tty --yes --passphrase-fd 3 -o $DIR/arch-root-${DATE}.tar.$COMPRESSEXT.gpg
echo "$PASS" >&3
tar -cvf - -C /boot --numeric-owner --preserve-permissions --one-file-system /boot | $COMPRESSOR | gpg -c --cipher-algo AES256 --batch --no-tty --yes --passphrase-fd 3 -o $DIR/arch-boot-${DATE}.tar.$COMPRESSEXT.gpg
echo "$PASS" >&3
tar -cvf - -C /home/"$USER" --numeric-owner --preserve-permissions --one-file-system "${dotfiles[@]}" | $COMPRESSOR | gpg -c --cipher-algo AES256 --batch --no-tty --yes --passphrase-fd 3 -o $DIR/arch-dotfiles-${DATE}.tar.$COMPRESSEXT.gpg

chown -R "$USER":users "$DIR"

rm backup.fifo

echo "done"
