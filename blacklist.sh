#!/bin/bash
{
echo "Blacklist update started"
}  > /config/scripts/blacklist-processing.txt

real_list=$(grep -B1 "Dynamic Threat List" /config/config.boot | head -n 1 | awk '{print $2}')
[[ -z "$real_list" ]] && { echo "aborting"; exit 1; } || echo "Updating $real_list"

ipset_list="temporary-list"

usgupt=$(uptime | awk '{print $4}')

backupexists="/config/scripts/blacklist-backup.bak"

process_blacklist () {
	/sbin/ipset -! destroy $ipset_list
	/sbin/ipset create $ipset_list hash:net

	for url in https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_webclient.netset
	do
		echo "Fetching and processing $url"
		{
		echo "Processing blacklist"
		date
		echo $url
		} >> /config/scripts/blacklist-processing.txt
		curl "$url" | awk '/^[1-9]/ { print $1 }' | xargs -n1 /sbin/ipset -! add $ipset_list
	done

	tlcontents=$(/sbin/ipset list $ipset_list | grep -A1 "Members:" | sed -n '2p')

	if [ -z "$tlcontents" ]
	then 
		{
		echo "Temporary list is empty, not backing up or swapping list. Leaving current list and contents in place."
		date
		} >> /config/scripts/blacklist-processing.txt
	else 
		/sbin/ipset save $ipset_list -f /config/scripts/blacklist-backup.bak
		/sbin/ipset swap $ipset_list "$real_list"
		{
		echo "Blacklist is updated and backed up"
		date
		} >> /config/scripts/blacklist-processing.txt
	fi

	{
	echo "Blacklist contents"
	/sbin/ipset list -s "$real_list"
	} >> /config/scripts/blacklist-processing.txt
	
	if [ "$usgupt" != "min," ]
	then
		{
		echo "Blacklist changes compared to previous run"
		} >> /config/scripts/blacklist-processing.txt
		
		for Nip in $(/sbin/ipset list "$real_list" | awk '/^[1-9]/ { print }')
		do
			if /sbin/ipset test $ipset_list "$Nip"; [ $? != 0 ]
			then
				{
				echo "ADDED $Nip to the list"
				} >> /config/scripts/blacklist-processing.txt
			fi
		done
	fi
	
	if [ "$usgupt" != "min," ]
	then
		for Oip in $(/sbin/ipset list $ipset_list | awk '/^[1-9]/ { print }')
		do
			if /sbin/ipset test "$real_list" "$Oip"; [ $? != 0 ]
			then
				{
				echo "REMOVED $Oip from the list"
				} >> /config/scripts/blacklist-processing.txt
			fi
		done
		
		{
		echo "Blacklist comparison complete"
		} >> /config/scripts/blacklist-processing.txt
		
	fi
	
	{
	echo "Blacklist processing finished"
	date
	} >> /config/scripts/blacklist-processing.txt
 
	/sbin/ipset destroy $ipset_list
}

if [ "$usgupt" == "min," ] && [ -e $backupexists ]
then
	{
	echo "USG uptime is less than one hour, and backup list is found" 
	echo "Loading previous version of blacklist. This will speed up provisioning"
	date
	} >> /config/scripts/blacklist-processing.txt
	/sbin/ipset restore -f /config/scripts/blacklist-backup.bak
	/sbin/ipset swap $ipset_list "$real_list"
	/sbin/ipset -! destroy $ipset_list
	{
	echo "Blacklist contents"
	/sbin/ipset list -s "$real_list"
	echo "Restoration of blacklist backup complete"
	date
	} >> /config/scripts/blacklist-processing.txt
elif [ "$usgupt" == "min," ] && [ ! -e $backupexists ]
then
	{
	echo "USG uptime is less than one hour, but backup list is not found"
	echo "Proceeding to create new blacklist. This will delay provisioning, but ensure you are protected"
	echo "Blacklist changes will not be compared as this is the first creation of the list"
	date
	} >> /config/scripts/blacklist-processing.txt
	process_blacklist
else
	{
	echo "Routine processing of blacklist started"
	date
	} >> /config/scripts/blacklist-processing.txt
	process_blacklist
fi
