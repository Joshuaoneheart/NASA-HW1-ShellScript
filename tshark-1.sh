#!/bin/bash
sources=$(tshark -r hw1-tshark.pcapng -T fields -e ip.src -Y "ip.src==$1")
res=0
for source in $sources
do
	res=$(($res + 1))
done
echo $res
