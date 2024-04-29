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

#this is will disable the default node js 
dnf module disable nodejs -y &>>fileName.log
validate $? "disabled the nodejs default"
dnf module enable nodejs:20 -y &>>fileName.log
validate $? "enabled the nodejs::20 is"
dnf install nodejs -y &>>fileName.log
validate $? "Installed the nodejs"

# if you are directly add user without any vaildation then if u run multiple times then this script will fail 
#useradd expense

# below command will check whether expense id is there or not. if its not there then we have add user.
id expense &>>$fileName
if [ $? -ne 0 ]
then
useradd expense
validate $? "expense user created"
else
echo -e "already user expense added... $yellow skipping $normal"
fi

#if you put as -p then if the directory is not there it will create other wise it will ignore
mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "download zip file"

cd /app

rm -rf /app/* 
#idemopontent so we are removing the everything whatever we have created in the app folder so that multiple time if you run there will be no problem
unzip /tmp/backend.zip &>>$fileName
validate $? "unzipped the backend code"

npm install
validate $? "npm installed"
#check your repo and path
cp /home/ec2-user/expense-project-script/expense-shell/backend.service /etc/systemd/system/backend.service &>>$fileName
validate $? "Copied backend service"

systemctl daemon-reload &>>$fileName
validate $? "daemon reloaded"
systemctl start backend &>>$fileName
validate $? "backend service started"

systemctl enable backend &>>$fileName
validate $? "enabled backend service"

dnf install mysql -y &>>$fileName #ExpenseApp@1
mysql -h db.vijaysai.online -uroot -p${mysql_root_password} < /app/schema/backend.sql

systemctl restart backend &>>$fileName
validate $? "backend service restarted"

