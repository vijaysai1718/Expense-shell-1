#!/bin/bash

user=$( id -u )
scriptName=$( echo $0 | cut -d "." -f1 )
timeStamp=$( date +%F-%H-%M-%S)
fileName=/tmp/$scriptName-$timeStamp.log

echo "please enter the password for the mysql root user"

read -s mysql_root_password

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

dnf install mysql-server -y &>>$fileName

validate $? "mysql-server installation is"

systemctl enable mysqld &>>$fileName
validate $? "mysqld server got enabled "

systemctl start mysqld
validate $? "mysqld server started"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

#Below code will be useful for idempotent nature
#below command will be checking whether we are able to get the list of db or not 
#If we are getting then already password already been set so no need of setting password again which will cause for an issue
mysql -h 34.226.190.65 -uroot -p${mysql_root_password} -e 'show databases;' &>>$fileName
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$fileName
    validate $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$yellow SKIPPING $normal"
fi



#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter DB password:"
read -s mysql_root_password
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
       echo -e "$2...$G SUCCESS $N"
    fi       
        

}
if  [ $USERID -ne 0 ]
then
    echo "please run this script with root access."
    exit 1
else
     echo "you are super user."
fi
dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disablind defualt nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then  
    useradd expense  &>>$LOGFILE
    VALIDATE $? "creating expense user"
else 
    echo -e "expense ser alreadsy created...$Y skipping $N"    

fi
mkdir -p /app &>>$LOGFILE
VALIDATE $? "craeting app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/devops-shell-script/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copied backend service"


systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"


mysql -h db.vijaysai.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"