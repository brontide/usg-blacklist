#!/bin/bash
echo "Blacklist update started" > /config/scripts/blacklist-processing.txt ; 
date >> /config/scripts/blacklist-processing.txt ;

real_list=$(grep -B1 "Dynamic Threat List" /config/config.boot | head -n 1 | awk '{print $2}'); [[ -z "$real_list" ]] && { echo "aborting"; exit 1; } || echo "Updating $real_list";

ipset_list='temporary-list' ;

sudo /sbin/ipset -! destroy $ipset_list ;
sudo /sbin/ipset create $ipset_list hash:net ;

for url in https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_webclient.netset
do echo "Fetching and processing $url" ;
 { echo "Processing blacklist" ; 
  date ; 
  echo $url ;
 } >> /config/scripts/blacklist-processing.txt ;
 curl "$url" | awk '/^[1-9]/ { print $1 }' | xargs -n1 sudo ipset -exist add $ipset_list ;
done ;

sudo /sbin/ipset swap $ipset_list "$real_list" ;

{ echo "Blacklist update finished" ; 
 date ; 
 echo "Blacklist contents" ; 
 sudo /sbin/ipset list -s "$real_list" ;
 } >> /config/scripts/blacklist-processing.txt ;
 
sudo /sbin/ipset destroy $ipset_list ;
