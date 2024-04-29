#!/bin/bash

source ./common.sh

check

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
cp /home/ec2-user/Expense-shell-1/expense.conf /etc/nginx/default.d/expense.conf &>>$fileName
validate $? "Copied expense conf"

systemctl restart nginx &>>$fileName
validate $? "Restarting nginx"
