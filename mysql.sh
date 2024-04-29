#!/bin/bash

source ./common.sh

check

echo "please enter the password for the mysql root user"
read -s mysql_root_password

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
mysql -h db.vijaysai.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$fileName
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$fileName
    validate $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$yellow SKIPPING $normal"
fi

