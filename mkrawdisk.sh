#!/bin/bash

set -e

[ -n "$1" ] || { echo "Usage: $(basename $0) </dev/sdX>"; exit 1; }
[ -b "$1" ] || { echo "Invalid disk $1"; exit 1; }

disk="${1##*/}"

rawfile="/storage/machines/${disk}_disk_access.vmdk"
user=slava
group=users

test -e "$rawfile" && rm -f "$rawfile"
VBoxManage internalcommands createrawvmdk -filename "$rawfile" -rawdisk "$1"
chown "$user":"$group" "$rawfile"
