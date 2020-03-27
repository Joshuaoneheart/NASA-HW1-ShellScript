#!/bin/bash
file="hw1-tshark.pcapng"
MY_TEMP=$(mktemp)
sorted=$(tshark -r $file -e frame.len -T fields|sed "s/ /\n/g"|sort -run|head -n $1)
output=""
i=0
for item in $sorted
do
	sources=$(tshark -r $file  -o "gui.column.format:Time,%Yt,Source,%s,Destination,%d" -Y "frame.len==$item")
	echo "$sources" > $MY_TEMP
	while read line
	do
		if [[ $i -ge $1 ]];then
			break;
		fi
		i=$((i + 1))
		source="$(echo "$line"|sed "s/.[0-9]\{9\}//g"|awk '{printf"%s %s,%s,%s",$1,$2,$3,$5}')"
		echo "$source"
	done < $MY_TEMP
	if [[ $i -ge $1 ]];then
		break;
	fi
done
rm -rf $MY_TEMP
