#!/bin/bash
file="hw1-tshark.pcapng"
MY_TEMP=$(mktemp)
output=""
i=0
sources=$(tshark -r $file  -o "gui.column.format:Time,%Yt,Source,%s,Destination,%d,Length,%L"|sort -k 6nr -k 2)
echo "$sources" > $MY_TEMP
i=0
while read line
do
	if [[ $i -eq $(($1)) ]]; then
	break;
	fi
	i=$(($i + 1))
	source="$(echo "$line"|sed "s/.[0-9]\{9\}//g"|awk '{printf"%s %s,%s,%s",$1,$2,$3,$5}')"
	echo "$source"
done < $MY_TEMP
rm -rf $MY_TEMP
