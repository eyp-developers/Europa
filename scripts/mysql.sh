#!/usr/bin/env bash

echo ">>> Installing MySQL Server $3"

[[ -z "$2" ]] && { echo "!!! MySQL root password not set. Check the Vagrant file."; exit 1; }

mysql_package=mysql-server

if [ $3 == "5.6" ]; then
    # Add repo for MySQL 5.6
	sudo add-apt-repository -y ppa:ondrej/mysql-5.6

	# Update Again
	sudo apt-get update

	# Change package
	mysql_package=mysql-server-5.6
fi

# Install MySQL without password prompt
# Set username and password to 'root'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $2"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $2"

# Install MySQL Server
# -qq implies -y --force-yes
sudo apt-get install -qq $mysql_package

# Change the root user to 'europa'
MYSQL=`which mysql`

Q1="update mysql.user set user='$1' where user='root';"
Q2="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}"

echo "executing $SQL with user $1 and password $2"

$MYSQL -uroot -p$2 -e "$SQL"

# Make MySQL connectable from outside world without SSH tunnel
if [ $4 == "true" ]; then
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this

    Q1="GRANT ALL ON *.* TO '$1'@'%' IDENTIFIED BY '$2' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -$1 -p$2 -e "$SQL"

    service mysql restart

fi

service mysql restart