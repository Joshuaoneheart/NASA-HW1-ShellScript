#!/bin/bash
function trap_ctrlc ()
{
	exit 0
}
trap graceful_exit EXIT
function graceful_exit()
{
	sock="$(echo $SSH_AUTH_SOCK|sed "s/[^\/]*$//"|sed "s/\/$//g")"
	rm -rf $sock
	if [[ $(ps|grep -c $SSH_AGENT_PID) -ne 0 ]]; then		
		kill $SSH_AGENT_PID
	fi
	rm -rf $MY_TEMP
}
trap trap_ctrlc INT
check(){
	if [[ $(($(($(echo "$1"|wc -m))) - $(($2)) - 1)) -gt 0 ]]; then 
		echo "The hostnames, alias names, or usernames contain name whose length is greater than regulated maximum length"
		echo "Try './deploy -h' option to get some helps"
		exit 0
	fi
}
arguNum=$#
if [[ $arguNum -lt 2 ]]; then
	echo "You have missed some necessary arguments"
	echo "Try './deploy -h' option to get some helps"
	rm -rf $MY_TEMP
	exit 1
fi
eval $(ssh-agent) &> /dev/null
oDir=""
cDir="./deploy.conf"
MY_TEMP=`mktemp -d`
hExist=false
cExist=false
pExist=false
for ((i = 0; i < $#; i++))
do
	argu=${!i}
if [[ $(echo $argu|grep -c '\-c') -ne 0 ]]; then
	i=$(($i+1))
	if [[ $i -ge $(($arguNum - 1)) || $(echo ${!i}|grep -c '\-') -ne 0 ]]; then
		echo "You must specify a file address when using -c option"
		echo "Try './deploy -h' option to get some helps"
		exit 0
	else 
		cExist=true
		cDir=${!i}
		shift 2
		i=$(($i-3))
	fi
elif [[ $(echo $argu|grep -c '\-o') -ne 0 ]];then
	i=$(($i+1))
	if [[ $i -ge $(($arguNum - 1)) || $(echo ${!i}|grep -c '\-') -ne 0 ]]; then
		echo "You must specify a file address when using -o option"
		echo "Try './deploy -h' option to get some helps"
		exit 0
	fi
	oDir=${!i}
	shift 2
	i=$(($i-3))
elif [[ $(echo $argu|grep -c '\-p') -ne 0 ]];then
	pExist=true
	shift 1
elif [[ $(echo $argu|grep -c '\-h') -ne 0 ]];then
	hExist=true
	break
fi
done
if $hExist ; then
	echo "Usage: ./deploy [OPTION]... [HOST] [COMMAND]"
	echo "A tool help user to run commands on remote hosts with a default configuration file ./deploy.conf."
	echo ""
	echo "Options:"
	echo "-c [file]  Specify the path of the configuration file instead of the default"
	echo "           file, ~/deploy.conf"
	echo "-o [file]  Print all messages (including stdout and stderr) except"
	echo "           password/passphrase prompt to a file instead of terminal"
	echo "           The configuration file should consist of multiple lines," 
	echo "           with the following format:"
	echo "           alias_name host[,hosts...]"
	echo "           Notice that each line of the file can only contain one space"
	echo "-p         Start all SSH connections in parallel."
	echo "-h         Print a help message"
	echo "Notice that the maximum length of hostnames, alias namew, and usernames are 256, 256, and 32, respectively"
	exit 0
fi
if [[ $# -gt 2 ]]; then
	echo "Incorrect command-line argument format"
	echo "Try './deploy -h' option to get some helps"
	exit 0
fi
hosts=$1
shift 1
command=$@
if [[ -z $hosts || -z $command ]]; then
	echo "You have missed some necessary arguments"
	echo "Try './deploy -h' option to get some helps"
	exit 0
fi
if [[ ! -e $cDir ]] && $cExist; then
	echo "Can't find file $cDir"
	echo "Try './deploy -h' option to get some helps"
	exit 0
elif [[ -e $cDir ]];then
	cExist=true
fi
if $cExist; then
$(tac $cDir > $MY_TEMP/temp_c)
if [[ $(echo $hosts|grep -c -e ",[ ]{0,}," -e "^," -e ",$") -ne 0 ]]; then
	echo "Hostnames in incorrect format"
	echo "Try './deploy -h' option to get some helps"
	exit 0
fi
hosts=( $(echo $hosts|sed "s/,/\n/g") )
declare -A haveAlias
while read line
do
	if [[ $(echo "$line"|grep -c " .* ") -ne 0 ]]; then
		echo "The content of the configuration file is in the incorrect format"
		echo "Try './deploy -h' option to get some helps"
		exit 0
	fi
	array=( $line )
	if [[ $(echo ${array[1]}|grep -c -e ",[ ]{0,}," -e "^," -e ",$") -ne 0 ]]; then
		echo "The content of the configuration file is in the incorrect format"
		echo "Try './deploy -h' option to get some helps"
		exit 0
	fi
	if test "${haveAlias[${array[0]}]}"; then
		echo "The content of the configuration file is in the incorrect format"
		echo "Try './deploy -h' option to get some helps"
		exit 0
	else
		haveAlias[${array[0]}]=true
	fi
	check ${array[0]} 256
		hosts=( $(echo "${hosts[@]}"|sed "s/,/\n/g") )
		for((i = 0;i < ${#hosts[@]};i++))
		do
			declare -A have
			host=${hosts[i]}
			if test "${have[$host]}"; then
				unset hosts[$i]
				continue
			else
				have[$host]=true
			fi
			replaceLine=$(echo "$host"|grep @${array[0]})
			if [[ -n $replaceLine ]]; then
			replaceArray=( $(echo $replaceLine|sed "s/@/ /g") )
			check ${replaceArray[0]} 32
			substitute=( $(echo ${array[1]}|sed "s/,/\n/g") )
			for((j = 0;j < ${#substitute[@]};j++))
			do
				if [[ $(echo ${substitute[j]}|grep -c @) -eq 0 ]]; then
					substitute[j]="${replaceArray[0]}@${substitute[j]}"
				fi
			done
			substitute=${substitute[@]}
			hosts=( $(echo "${hosts[@]}"|sed "s/$replaceLine/$substitute/g") )
			else
			hosts=( $(echo "${hosts[@]}"|sed "s/${array[0]}/${array[1]}/g") )
		fi
	done
	unset have
	done < $MY_TEMP/temp_c
fi
if [[ -n $oDir ]];then
	oDir="> $oDir 2> $oDir"
fi
for((i = 0;i < ${#hosts[@]};i++))
do
	host=${hosts[$i]}
	user=( $(echo $host|sed "s/@/ /g") )
	check ${user[0]} 32
	check $host 256
	echo "==== $host ===="
	if [[ -n $oDir ]];then
		sshCommand="ssh -o AddKeysToAgent=yes $host "$command" $oDir"
	else
		sshCommand="ssh -o AddKeysToAgent=yes $host "$command""
	fi
	echo $(eval "$sshCommand")
done
exit 0
