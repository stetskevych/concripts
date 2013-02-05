# /etc/profile.d/great-advice.sh
[[ "$(id -u)" != 0 ]] && \
( echo -e `curl -s  http://fucking-great-advice.ru/api/random | awk -F \" '{print $8}'` |sed 's/\&nbsp;/ /g' )
