#!/bin/bash

real_list=`grep -B1 "Dynamic Threat List" /config/config.boot | head -n 1 | awk '{print $2}'`
[[ -z "$real_list" ]] && { echo "aborting"; exit -1; } || echo "Updating $real_list"

ipset_list='temporary-list'

sudo /sbin/ipset -! destroy $ipset_list
sudo /sbin/ipset create $ipset_list hash:net

for url in 'https://www.spamhaus.org/drop/drop.txt' 'https://www.spamhaus.org/drop/edrop.txt' 'http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt' 'https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1';
do
 echo "Fetching and processing $url"
 curl $url | awk '/^[1-9]/ { print $1 }' | xargs -n1 sudo ipset -q add $ipset_list
done

sudo /sbin/ipset swap $ipset_list $real_list
sudo /sbin/ipset destroy $ipset_list
