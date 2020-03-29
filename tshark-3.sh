#!/bin/bash
sources="$(tshark -r hw1-tshark.pcapng -Y "dns" -T fields -e ip.src|sed "s/,[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//g"|sort)"
sources="$(echo "$sources"|uniq -c|sort -k2|sort -nr -k1)"
echo "$sources"
sources=$(echo "$sources"|head -n $1|sed "s/^[ ]*//g"|sed "s/ /,/g")
for line in $(echo "$sources")
do
	line=( $(echo $line|sed "s/,/ /g") )
	line="${line[1]} ${line[0]}"
	echo $(echo $line|sed "s/ /,/g")
done

