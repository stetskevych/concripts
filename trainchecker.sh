#!/bin/bash
# Check for Dnipro - Kyiv train tickets availability
# TODO: should use http://booking.uz.gov.ua instead, but it has elaborate blocking for external automation
#*/3 * * * * /home/vst/trainchecker.sh 1>>/home/vst/trainchecker.out 2>&1

res="$(curl 'http://miykvytok.com/api/?m=getTrains' -H 'Pragma: no-cache' -H 'OrAccept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.75 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Referer: http://miykvytok.com/train' --data 'code1=2210700&code2=2200001&date1=08.05.2016&time1=20%3A00&tudaobratno=false&data_class=train' --compressed -s)"

[[ $res =~ 'Поездов не найдено' ]] || { echo "$res" | mail -s 'Some trains found' my@addre.ss; }
