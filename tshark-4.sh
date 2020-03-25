#!/bin/bash
tshark -r hw1-tshark.pcapng -qz "io,stat,1,SUM(frame.len)frame.len"|sed "s/Dur/Dur /g"|awk '{printf"%s %s\n",$2,$6}'|sed "s/[^0-9 ]//g"|sort -k2 -nr|awk '{printf"%s\n",$1}'|head -n $1
#|sort -nr|head -n 80
#sources=$(tshark -r hw1-tshark.pcapng -o "gui.column.format:Time,%t,Length,%L")
#echo "$sources"|sed "s/.[0-9]\{9\}//g"|awk '{arr[$1]+=int($2)}'
# {for(i in arr)printf"%s %s\n",$i,arr[i]}'>output
#|sort -k2 -rn >output
#|awk '{printf"%s\n",$1}'|head -n $1
