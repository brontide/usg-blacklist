# Dynamic Blacklisting for the Unifi USG router

Having migrated from EdgeRouter to USG I wanted to bring over one script that kept a daily dynamic blacklist updated
from several reputable sources.  The script itself is quite simple but requires setup within the conttroller to work
correctly.

1. Setup a firewall IPv4 group called "Dynamic Threat List".  The name is important because it's used by the script.
1. Setup firewall WAN_IN, WAN_OUT rules to drop traffic from/to this group.
1. Install the script into /config/scripts. 
1. Create a config.gateway.json to run this script periodically.

# View counters.

   sudo iptables -vL WAN_IN

# References.

https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-How-to-further-customize-USG-configuration-with-config-gateway-json

https://community.ubnt.com/t5/UniFi-Routing-Switching/Custom-bash-script-in-USG/td-p/2023554
