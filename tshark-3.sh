#!/bin/bash
sources=$(tshark -r hw1-tshark.pcapng -Y "dns.flags.response==0||dns.flags.response==1" -T fields -e ip.src|sort|uniq -c|sort -nr)
sources=$(echo "$sources"|head -n $1|sed "s/^[ ]*//g"|sed "s/ /,/g")
for line in $(echo "$sources")
do
	line=( $(echo $line|sed "s/,/ /g") )
	line="${line[1]} ${line[0]}"
	echo $(echo $line|sed "s/ /,/g")
done
