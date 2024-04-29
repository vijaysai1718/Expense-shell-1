#!/bin/bash

user=$( id -u )
scriptName=$( echo $0 | cut -d "." -f1 )
timeStamp=$( date +%F-%H-%M-%S)
fileName=/tmp/$scriptName-$timeStamp.log



red="\e[31m"
green="\e[32m"
normal="\e[0m"
yellow="\e[33m"
if [ $user -ne 0 ]
then
echo "hey man you are not having access to run this script please get the root access or try with super access"
exit 1
else
echo "User is having super access"
fi

validate()

if [ $1 -ne 0 ]
then
echo -e "$2  got $red failed $normal please check the logs for more details"
exit 1
else
echo -e " $2  $green success $normal"
fi

dnf install nginx -y &>>$fileName
validate $? "Installing nginx"

systemctl enable nginx &>>$fileName
validate $? "Enabling nginx"

systemctl start nginx &>>$fileName
validate $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$fileName
validate $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$fileName
validate $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$fileName
unzip /tmp/frontend.zip &>>$fileName
validate $? "Extracting frontend code"

#check your repo and path
cp /home/ec2-user/expense-project-script/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$fileName
validate $? "Copied expense conf"

systemctl restart nginx &>>$fileName
validate $? "Restarting nginx"
