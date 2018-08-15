FROM php:7.2.8-apache

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Apache extensions
RUN apt-get update && \
    apt-get -y install \
    apache2-utils pwgen vim nano \
    libmemcached-dev memcached libmemcached-tools wget curl libapache2-mod-evasive libapache2-mod-security2 && \
    a2enmod headers && a2enmod evasive && a2enmod rewrite && a2enmod ssl

# Some extensions
RUN apt-get install -y libncurses5 libncurses5-dev libncursesw5 libncursesw5-dev geoip-bin libgeoip-dev libgeoip1 \
    geoip-database geoip-database-extra libxslt1-dev libxslt1.1 libxml2-dev libxml2 libtidy-dev libtidy5 tidy  \
    sqlite3 libsqlite3-0 libsqlite3-dev sqlite libpspell-dev pdf2htmlex \
    ssl-cert openssl libcurl3 libssl-dev
    

# ImageMagick
RUN apt-get install -y imagemagick libmagickwand-dev libmagickwand-dev libmagickcore-dev libpam-pwdfile

# PHP ZipArchive extension
RUN apt-get update \
  && apt-get install -y zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install zip

# Configure extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install bcmath
# RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install zip
RUN docker-php-ext-install bz2 calendar ctype dba dom exif fileinfo 
RUN docker-php-ext-install ftp gettext hash iconv json 
RUN docker-php-ext-install opcache pcntl pdo pdo_mysql pdo_sqlite 
RUN docker-php-ext-install posix pspell session 
RUN docker-php-ext-install shmop simplexml soap sockets sysvmsg sysvsem sysvshm tidy tokenizer wddx 
RUN docker-php-ext-install xml xmlrpc xmlwriter xsl 

RUN pecl install imagick
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini
RUN docker-php-ext-enable imagick
# RUN docker-php-ext-install xsl

ADD  ./src/apache2/*.conf /etc/apache2/sites-available/
COPY ./src/apache2/*.template /etc/apache2/sites-available/
RUN useradd -ms /bin/bash mark && usermod -a -G www-data mark

# cron for background tasks

RUN apt-get update && apt-get install -y cron supervisor mysql-client
RUN mkdir -p /var/log/supervisor
COPY ./src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD  ./src/crontab /var/spool/cron/crontabs/root
RUN chmod 0644 /var/spool/cron/crontabs/root
RUN touch /var/log/cron.log

ADD ./src/goaccess.sh /usr/local/bin/goaccess.sh
ADD ./src/init.sh /usr/local/bin/init.sh
ADD ./src/run.sh /usr/local/bin/run.sh
RUN chmod 755 /usr/local/bin/*.sh

CMD ["/usr/local/bin/run.sh"]
