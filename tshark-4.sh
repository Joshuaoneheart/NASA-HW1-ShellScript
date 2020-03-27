#!/bin/bash
tshark -r hw1-tshark.pcapng -qz "io,stat,1,SUM(frame.len)frame.len"|sed "s/Dur/Dur /g"|awk '{printf"%s %s\n",$2,$6}'|sed "s/[^0-9 ]//g"|sort -k2 -nr|awk '{printf"%s\n",$1}'|uniq|sed -e '$d'|head -n $1
