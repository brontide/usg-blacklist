# Dynamic IP/CIDR Blocklist for the Unifi USG router

Having a USG I wanted to create a script that kept a daily dynamic blocklist updated
from several reputable sources.  The script itself is quite simple but requires setup within the conttroller to work
correctly.

1. Setup a firewall IPv4 group called "FireHOL" with one place holder IPv4 address or subnet such as "192.168.0.0/16" as this address will always be in the list anyway as it is a bogon.  The name is important because it's used by the script.
1. Setup firewall WAN_IN (Internet In), WAN_LOCAL (Internet Local), WAN_OUT (Internet Out) rules to drop traffic from/to this group.
1. Install the script into /config/scripts on the USG.  Please check the files before running.
   
   ```
   sudo curl -o /config/scripts/blocklist.sh https://raw.githubusercontent.com/FastEddy1114/usg-blacklist/master/blocklist.sh
   sudo chmod +x /config/scripts/blocklist.sh
   ```
1. Create symbolic link so script runs on USG reboot in addition to scheduled interval

   ```
   sudo ln -s /config/scripts/blocklist.sh /config/scripts/post-config.d/blocklist.sh
   ```
1. Create/update config.gateway.json on your controller to run this script periodically.  Time interval specified in config.gateway.json file is always based on 00:00:00 (midnight) being the starting point.
1. Reboot USG to force immediate script execution or SSH into USG and run below command to force immediate script execution

   ```
   sudo /config/scripts/blocklist.sh
   ```

# View counters.

```
sudo iptables -vL WAN_LOCAL
```

If you have the rules set to log you will see this in dmesg and the syslog.

```
admin@Router:~$ dmesg | grep WAN_
[WAN_LOCAL-2000-D]IN=eth0 OUT= MAC=fc:ec:xx:43:xx:22:xx:01:xx:7c:xx:46:xx:00 SRC=181.214.87.226 DST=108.183.yy.yy LEN=40 TOS=0x00 PREC=0x00 TTL=242 ID=36903 PROTO=TCP SPT=51546 DPT=9237 WINDOW=1024 RES=0x00 SYN URGP=0 
[WAN_LOCAL-2000-D]IN=eth0 OUT= MAC=fc:ec:xx:43:xx:22:xx:01:xx:7c:xx:46:xx:00 SRC=5.188.11.91 DST=108.183.yy.yy LEN=40 TOS=0x08 PREC=0x00 TTL=243 ID=31623 PROTO=TCP SPT=40231 DPT=6091 WINDOW=1024 RES=0x00 SYN URGP=0 
[WAN_LOCAL-2000-D]IN=eth0 OUT= MAC=fc:ec:xx:43:xx:22:xx:01:xx:7c:xx:46:xx:00 SRC=191.101.167.61 DST=108.183.yy.yy LEN=40 TOS=0x08 PREC=0x00 TTL=244 ID=43130 PROTO=TCP SPT=54342 DPT=13165 WINDOW=1024 RES=0x00 SYN URGP=0 
[WAN_LOCAL-2000-D]IN=eth0 OUT= MAC=fc:ec:xx:43:xx:22:xx:01:xx:7c:xx:46:xx:00 SRC=5.188.11.95 DST=108.183.yy.yy LEN=40 TOS=0x08 PREC=0x00 TTL=244 ID=43978 PROTO=TCP SPT=54347 DPT=9302 WINDOW=1024 RES=0x00 SYN URGP=0 
```

# References.

https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-How-to-further-customize-USG-configuration-with-config-gateway-json

https://community.ubnt.com/t5/UniFi-Routing-Switching/Custom-bash-script-in-USG/td-p/2023554
