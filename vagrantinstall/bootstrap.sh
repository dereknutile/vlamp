#!/usr/bin/env bash
################################################################################
# Main shell script for enhancing a base vagrant box.  I've broken out each area
# into what I think is logical so we can turn on or off any components.
################################################################################


# Simple callable functions ####################################################
# Add an apt repo
function addrepo {
    echo 'Adding Repository' $1
    shift
    apt-add-repository -y install "$@" >/dev/null 2>&1
}

# Install using apt-get
function inst {
    echo 'Installing' $1
    shift
    # apt-get -y install "$@" >/dev/null 2>&1
    apt-get -y install "$@"
}
################################################################################

echo "Bootstrap.sh initialized."

# System updates ###############################################################
# Drop in ppa's here before the apt-get update later

# Ubuntu/Debian system update
echo System Update with apt-get
apt-get -y update >/dev/null 2>&1
apt-get -y upgrade >/dev/null 2>&1

# Build essentials are required for some things like Redis
inst 'Build Essentials Development Tools' build-essential

# Install make
inst 'Make' make
################################################################################


# Miscellaneous apps and requirements ##########################################
# Install NodeJs
inst 'NodeJS' nodejs

# Install the Node Package Manager
inst 'Node Package Manager' npm

# install With Bower, Grunt, and Gulp here
npm install -g bower
npm install -g grunt
npm install -g gulp
################################################################################


# Git setup ####################################################################
# Install Git
inst 'Git' git
################################################################################


# Web server installs ##########################################################
# Install Apache
inst 'Apache2' apache2

# overwrite the default Apache2 server configuration for the vagrant app
sudo echo "ServerName localhost" >> /etc/apache2/apache2.conf
# Backup and link the default apache directory
sudo mv html/ html.original
sudo ln -s /vagrant/public /var/www/html
################################################################################


# Database installs ############################################################
# Install SQLite
inst 'SQLite' sqlite3 libsqlite3-dev

# Install Redis
inst 'Redis' redis-server

# Install RabbitMQ Messaging
inst 'RabbitMQ' rabbitmq-server

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# MySQL Server
# inst 'MySQL Client Core' mysql-client-core-5.5
inst 'MySQL Server' mysql-server
inst 'MySQL Client Library' libmysqlclient-dev
################################################################################


# PHP setup ####################################################################
inst 'Mcrypt' mcrypt
inst 'Installing PHP and libraries' php5-mysql php5 php5-cli libapache2-mod-php5 php5-mcrypt php5-common php5-json php5-curl php5-gd php5-imagick php5-imap php5-memcached
echo Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/
mv /usr/local/bin/composer.phar /usr/local/bin/composer
echo Composer update
/usr/local/bin/composer global update
################################################################################


# Service setup ################################################################
# Restart Apache2
echo Restarting Apache2
service apache2 restart

# Restart MySQL
echo Restarting MySQL
service mysql restart
################################################################################

echo 'Boostrap.sh complete!'
echo '---------------------'
echo 'Check your browser at http://localhost:8080/ to confirm.'
