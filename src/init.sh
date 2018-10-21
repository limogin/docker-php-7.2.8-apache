#!/bin/bash

# Apache Setup
cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
cd /etc/apache2/sites-available/

# Define virtualhosts

for i in `seq 1 30`
do
  Q="SITE$i"
  eval "SITENDX=\${$Q}"
  if [ "$SITENDX" ];
  	then
  	  echo "setting virtualhost $SITENDX .. "
  	  cp /etc/apache2/sites-available/virtualhost.template ${SITENDX}.conf
  	  sed -ri -e "s/SERVERNAME/${SITENDX}/" /etc/apache2/sites-available/${SITENDX}.conf
  	  a2ensite ${SITENDX}.conf
  	  [ -d /var/www/${SITENDX} ] || mkdir -p /var/www/html/${SITENDX}
  	  [ -d /var/www/${SITENDX}/www ] || mkdir -p /var/www/html/${SITENDX}/www
      [ -d /var/www/${SITENDX}/tasks ] || mkdir -p /var/www/html/${SITENDX}/tasks
      [ -d /var/www/${SITENDX}/data ] || mkdir -p /var/www/html/${SITENDX}/data
      if [ "$SITE" == "$SITENDX" ];
        then
          sed -ri -e "s/SERVERALIAS/www.${SITENDX} \*/" /etc/apache2/sites-available/${SITENDX}.conf
        else
          sed -ri -e "s/SERVERALIAS/www.${SITENDX}/"   /etc/apache2/sites-available/${SITENDX}.conf
      fi
  fi
done


cd /etc/apache2
sed -ri -e "s/ServerName.*/ServerName ${SITE}/" /etc/apache2/sites-available/000-default.conf
sed -ri -e "s#DocumentRoot.*#DocumentRoot /var/www/html/default/www#" /etc/apache2/sites-available/000-default.conf
sed -ri -e "s/ServerName.*/ServerName ${SITE}/" /etc/apache2/sites-available/default-ssl.conf
sed -ri -e "s#DocumentRoot.*#DocumentRoot /var/www/html/default/www#" /etc/apache2/sites-available/default-ssl.conf

# Setup basic php.ini

sed -ri -e "s/upload_max_filesize =.*/upload_max_filesize = 64M/" /etc/php5/apache2/php.ini
sed -ri -e "s/short_open_tag =.*/short_open_tag = On/" /etc/php5/apache2/php.ini
sed -ri -e "s/memory_limit =.*/memory_limit = 256M/" /etc/php5/apache2/php.ini
sed -ri -e "s/post_max_size =.*/post_max_size = 64M/" /etc/php5/apache2/php.ini
sed -ri -e "s/short_open_tag =.*/short_open_tag = On/" /etc/php5/apache2/php.ini
sed -ri -e "s/display_errors =.*/display_errors = On/" /etc/php5/apache2/php.ini

sed -ri -e "s/upload_max_filesize =.*/upload_max_filesize = 64M/" /etc/php5/cli/php.ini
sed -ri -e "s/short_open_tag =.*/short_open_tag = On/" /etc/php5/cli/php.ini
sed -ri -e "s/memory_limit =.*/memory_limit = 256M/" /etc/php5/cli/php.ini
sed -ri -e "s/post_max_size =.*/post_max_size = 64M/" /etc/php5/cli/php.ini
sed -ri -e "s/short_open_tag =.*/short_open_tag = On/" /etc/php5/cli/php.ini
sed -ri -e "s/display_errors =.*/display_errors = On/" /etc/php5/cli/php.ini

cp /etc/php5/apache2/php.ini  /usr/local/etc/php/php.ini

# setup some apache Security
mkdir -p /var/log/mod_evasive && chown www-data:www-data /var/log/mod_evasive/

if [ "$DOCKERENV" == "prod" ];
        
 echo "ServerSignature Off" >> /etc/apache2/apache2.conf
 echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
 echo "TraceEnable Off" >> /etc/apache2/apache2.conf
 echo "LimitRequestBody 0" >> /etc/apache2/apache2.conf

 cp /etc/modsecurity/modsecurity.conf-recommended 	/etc/modsecurity/modsecurity.conf
 sed -ri -e "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/modsecurity/modsecurity.conf
 sed -ri -e "s/SecResponseBodyAccess On/SecResponseBodyAccess Off/" /etc/modsecurity/modsecurity.conf
 sed -ri -e "s/SecRequestBodyLimit .*/SecRequestBodyLimit 131072000/" /etc/modsecurity/modsecurity.conf
 sed -ri -e "s/SecRequestBodyNoFilesLimit .*/SecRequestBodyNoFilesLimit 131072000/" /etc/modsecurity/modsecurity.conf
 sed -ri -e "s/SecRequestBodyInMemoryLimit .*/SecRequestBodyInMemoryLimit 131072000/" /etc/modsecurity/modsecurity.conf

fi

env | grep MYSQL > /etc/environtment

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=ES/ST=Spain/L=fpr/O=Dis/CN=fpr"

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

if [ "$APACHE_RUN_USER" ]; then 

 cp /etc/apache2/envvars /etc/apache2/envvars.backup
 sed -ri -e "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=${APACHE_RUN_USER}/" /etc/apache2/envvars
 sed -ri -e "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=${APACHE_RUN_GROUP}/" /etc/apache2/envvars

 adduser --disabled-password --gecos "" ${APACHE_RUN_USER}
 chown -R ${APACHE_RUN_USER}.${APACHE_RUN_GROUP} /var/www 

fi 

