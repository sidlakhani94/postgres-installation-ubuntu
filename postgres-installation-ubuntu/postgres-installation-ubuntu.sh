#!/bin/bash
#Author: Siddharth Lakhani
#Description: Install and configure Postgres in Ubuntu 18 and 16
#Date: 2020-11-05

psql --version > /dev/null 2>&1
if [ $? -gt 1 ]; then

    read -p "Enter Version of Postgresql: " version
    read -sp "Super User Password: " PASS_SU
    echo ""
    read -p "Enter Port Number: " NEW_PORT

    #Install Postgresql

    echo "**********Start Installing Postgresql***********"
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install postgresql-$version
    echo "*********Postgresql Installation Completed******"

    #Changing Postgres User Password

    echo "********Changing Password of Postgres user Database**************"
    sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$PASS_SU';"
    echo "********Postgresql Installed and Confiugred Successfully*********"

    #Configuring Postgresql

    echo "*******Configuring Postgresql******************"
    sudo sed -i "s/peer/md5/g" /etc/postgresql/$version/main/pg_hba.conf
    echo "host    all             all             0.0.0.0/0            md5" | sudo tee -a /etc/postgresql/$version/main/pg_hba.conf &> /dev/null
    echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/$version/main/postgresql.conf &> /dev/null

    Default_Port=$(sudo netstat -apn | grep tcp | grep postgres | head -n 1 | awk '{print $4}' | sed 's/^.*://')
    if [ $Default_Port -ne $NEW_PORT ]; then
        echo "port = $NEW_PORT" | sudo tee -a /etc/postgresql/$version/main/postgresql.conf &> /dev/null
        sudo ufw allow $NEW_PORT
        echo "Default Port of Postgresql Changed to $NEW_PORT"
    else
        echo "$NEW_PORT is Default Port of Postgresql"
    fi

    sudo service postgresql restart


else
    echo "*******Postgresql is already Installed**************************"
fi 
