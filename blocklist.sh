#!/bin/bash
{
echo "Blocklist update started"
}  > /config/scripts/blocklist-processing.txt

real_list=$(grep -B2 "FireHOL" /config/config.boot | head -n 1 | awk '{print $2}')
[[ -z "$real_list" ]] && { echo "aborting"; exit 1; } || echo "Will update FireHOL list ID $real_list"

ipset_list="temporary-list"

usgupt=$(uptime | awk '{print $4}')

backupexists="/config/scripts/blocklist-backup.bak"

if [ -e $backupexists ]
then
	backupexists="TRUE"
else
	backupexists="FALSE"
fi

process_blocklist () {
	/sbin/ipset -! destroy $ipset_list
	/sbin/ipset create $ipset_list hash:net

	for url in https://iplists.firehol.org/files/firehol_level1.netset https://iplists.firehol.org/files/firehol_level2.netset https://iplists.firehol.org/files/firehol_webclient.netset https://iplists.firehol.org/files/firehol_abusers_1d.netset https://iplists.firehol.org/files/myip.ipset https://iplists.firehol.org/files/tor_exits.ipset https://iplists.firehol.org/files/iblocklist_onion_router.netset
	do
		echo "Fetching and processing $url"
		{
		echo "Processing blocklist"
		date
		echo $url
		} >> /config/scripts/blocklist-processing.txt
		curl "$url" | awk '/^[1-9]/ { print $1 }' | xargs -n1 /sbin/ipset -! add $ipset_list
	done

	tlcontents=$(/sbin/ipset list $ipset_list | grep -A1 "Members:" | sed -n '2p')

	if [ -z "$tlcontents" ]
	then 
		echo "Temporary list is empty, not backing up or swapping list. Leaving current list and contents in place."
		{
		echo "Temporary list is empty, not backing up or swapping list. Leaving current list and contents in place."
		date
		} >> /config/scripts/blocklist-processing.txt
	else 
		/sbin/ipset save $ipset_list -f /config/scripts/blocklist-backup.bak
		/sbin/ipset swap $ipset_list "$real_list"
		echo "Blocklist is updated and backed up"
		{
		echo "Blocklist is updated and backed up"
		date
		} >> /config/scripts/blocklist-processing.txt
	fi

	{
	echo "Blocklist contents"
	/sbin/ipset list -s "$real_list"
	} >> /config/scripts/blocklist-processing.txt
	
<<Disabled
	if [ "$usgupt" != "min," ] && [ "$backupexists" == "TRUE" ]
	then
		echo "Processing changes compared to previous run"
		echo "To see the changes check the log located at /config/scripts/blocklist-processing.txt"
		{
		echo "Blocklist changes compared to previous run"
		} >> /config/scripts/blocklist-processing.txt
		
		for Nip in $(/sbin/ipset list "$real_list" | awk '/^[1-9]/ { print }')
		do
			NTotal=$((NTotal+1));
			
			if ! /sbin/ipset test $ipset_list "$Nip"
			then
				NChanges=$((NChanges+1));
				{
				echo "ADDED $Nip to the list"
				} >> /config/scripts/blocklist-processing.txt
			else
				NoneAdded=$((NoneAdded+1));
			fi
		done
		
		for Oip in $(/sbin/ipset list $ipset_list | awk '/^[1-9]/ { print }')
		do
			OTotal=$((OTotal+1));
			
			if ! /sbin/ipset test "$real_list" "$Oip"
			then
				OChanges=$((OChanges+1));
				{
				echo "REMOVED $Oip from the list"
				} >> /config/scripts/blocklist-processing.txt
			else
				NoneRemoved=$((NoneRemoved+1));
			fi
		done
		
		if [ $((NTotal + OTotal)) == $((NoneAdded + NoneRemoved)) ]
		then
			{
			echo "No changes"
			} >> /config/scripts/blocklist-processing.txt
		else
			TChanges=$((NChanges + OChanges));
			{
			echo "$NChanges additions"
			echo "$OChanges removals"
			echo "$TChanges total changes"
			} >> /config/scripts/blocklist-processing.txt
		fi
		
		echo "Blocklist comparison complete"
		{
		echo "Blocklist comparison complete"
		} >> /config/scripts/blocklist-processing.txt
	fi
Disabled
		
	{
	echo "Blocklist processing finished"
	date
	} >> /config/scripts/blocklist-processing.txt
 
	/sbin/ipset destroy $ipset_list
	echo "Blocklist processing finished"
}

if [ "$usgupt" == "min," ] && [ "$backupexists" = "TRUE" ]
then
	echo "USG uptime is less than one hour, and backup list is found" 
	echo "Loading previous version of blocklist. This will speed up provisioning"
	{
	echo "USG uptime is less than one hour, and backup list is found" 
	echo "Loading previous version of blocklist. This will speed up provisioning"
	date
	} >> /config/scripts/blocklist-processing.txt
	/sbin/ipset restore -f /config/scripts/blocklist-backup.bak
	/sbin/ipset swap $ipset_list "$real_list"
	/sbin/ipset -! destroy $ipset_list
	{
	echo "Blocklist contents"
	/sbin/ipset list -s "$real_list"
	echo "Restoration of blocklist backup complete"
	date
	} >> /config/scripts/blocklist-processing.txt
	echo "Restoration of blocklist backup complete"
elif [ "$usgupt" == "min," ] && [ "$backupexists" == "FALSE" ]
then
	echo "USG uptime is less than one hour, but backup list is not found"
	echo "Proceeding to create new blocklist. This will delay provisioning, but ensure you are protected"
	echo "Blocklist changes will not be compared as this is the first creation of the list"
	{
	echo "USG uptime is less than one hour, but backup list is not found"
	echo "Proceeding to create new blocklist. This will delay provisioning, but ensure you are protected"
	echo "Blocklist changes will not be compared as this is the first creation of the list"
	date
	} >> /config/scripts/blocklist-processing.txt
	process_blocklist
	echo "First time creation of blocklist complete"
else
	echo "Routine processing of blocklist started"
	{
	echo "Routine processing of blocklist started"
	date
	} >> /config/scripts/blocklist-processing.txt
	process_blocklist
	echo "Routine processing of blocklist complete"
fi
