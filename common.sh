#!/bin/bash

user=$( id -u )
scriptName=$( echo $0 | cut -d "." -f1 )
timeStamp=$( date +%F-%H-%M-%S)
fileName=/tmp/$scriptName-$timeStamp.log



red="\e[31m"
green="\e[32m"
normal="\e[0m"
yellow="\e[33m"

check()
{
if [ $user -ne 0 ]
then
echo "hey man you are not having access to run this script please get the root access or try with super access"
exit 1
else
echo "User is having super access"
fi
}



validate()
{
if [ $1 -ne 0 ]
then
echo -e "$2  got $red failed $normal please check the logs for more details"
exit 1
else
echo -e " $2  $green success $normal"
fi
}