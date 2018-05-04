# Dynamic Blacklisting for the Unifi USG router

Having migrated from EdgeRouter to USG I wanted to bring over one script that kept a daily dynamic blacklist updated
from several reputable sources.  The script itself is quite simple but requires setup within the conttroller to work
correctly.

1. Setup a firewall IPv4 group called "Dynamic Threat List".  The name is important because it's used by the script.
1. Setup firewall WAN_LOCAL, WAN_OUT rules to drop traffic from/to this group.
1. Install the script into /config/scripts on the USG.  Please check the files before running.
   
   ```
   sudo curl -o /config/scripts/blacklist.sh https://raw.githubusercontent.com/brontide/usg-blacklist/master/blacklist.sh
   sudo chmod 755 /config/scripts/blacklist.sh
   ```
1. Create/update config.gateway.json on your controller to run this script periodically.

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
