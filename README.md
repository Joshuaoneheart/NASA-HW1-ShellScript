# NASA-HW1-ShellScript
The shell script part of NASA HW1 in NTU CSIE.
### the command in use
##### Text processing
head, tail, sed, tr, paste, grep, cut, awk, sort, uniq, wc
##### Output
echo, printf
##### File manipulation
touch, mkdir, mktemp, mkfifo, rm, mv, cp, ls, find, cat, stat, pwd
##### Calculation 
bc
##### Process manipulation
ps, kill, lsof
##### Remote connection
ssh-related commands
##### Utilities
xargs, tar-related commands (including gzip, xz, etc.)
##### System information
date, uptime
##### Programs explicitly allowed in the problem description.

### help message of this tool
Usage: ./deploy [OPTION]... [HOST] [COMMAND]
A tool help user to run commands on remote hosts with a default configuration file ./deploy.conf.
  
Options:
-c [file]  Specify the path of the configuration file instead of the default"
          file, ~/deploy.conf"
-o [file]  Print all messages (including stdout and stderr) except"
           password/passphrase prompt to a file instead of terminal"
           The configuration file should consist of multiple lines," 
           with the following format:"
           alias_name host[,hosts...]"
           Notice that each line of the file can only contain one space"
-p         Start all SSH connections in parallel."
-h         Print a help message"
Notice that the maximum length of hostnames, alias names, and usernames are 256, 256, and 32, respectively"
  ### The deadline of this homework is 2020/3/29(Sun) 22:00
