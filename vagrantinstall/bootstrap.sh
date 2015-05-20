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

# overwrite the nginx default server configuration for the vagrant app
sudo cat > /etc/nginx/sites-available/default <<'EOF'
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  root /vagrant/public;
  index index.php index.html index.htm;

  server_name localhost;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
  }
}
EOF

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
inst mcrypt
inst 'Installing PHP' php5-mysql php5 php5-cli libapache2-mod-php5 php5-mcrypt php5-common php5-json php5-curl php5-gd php5-imagick php5-imap php5-memcached
echo Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/
mv /usr/local/bin/composer.phar /usr/local/bin/composer
/usr/local/bin/composer global require drush/drush
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
