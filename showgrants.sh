#!/bin/bash
tmp=/tmp/showgrants$$
mysql --batch --skip-column-names -e "SELECT user, host FROM user" mysql > "$tmp"
while read -r user host; do
  echo "# $user @ $host"
  mysql --batch --skip-column-names -e "SHOW GRANTS FOR '$user'@'$host'"
done < "$tmp"
rm $tmp
