FROM ubuntu:wily

MAINTAINER Fábio Luciano <fabio.goisl@ctis.com.br>

ENV COMPOSER_HOME /usr/share/composer/
ENV TIMEZONE            America/Sao_Paulo
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

RUN apt-get update --fix-missing \
  && apt-get dist-upgrade -y \
  && apt-get install --no-install-recommends -y supervisor tzdata \
  && apt-get install --no-install-recommends -y curl autoconf g++ gcc curl git \
  && apt-get install --no-install-recommends -y php5 libapache2-mod-php5 php5-dev php5-gd php5-geoip \
    php5-mcrypt php5-memcache php5-xsl php5-memcached php5-pgsql php5-xdebug \
    php5-curl php5-mongo php5-mysql php5-imagick php5-cli php-pear php5-dev

RUN apt-get install --no-install-recommends -y nginx php5-fpm

RUN apt-get remove --purge -y software-properties-common make \
  && apt-get autoremove -y && apt-get clean && apt-get autoclean \
  && echo -n > /var/lib/apt/extended_states \
  && rm -rf /var/lib/apt/lists/* /usr/share/man/?? /usr/share/man/??_*

RUN a2enmod rewrite



  # && sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php/php-fpm.conf \
  # && sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php/php-fpm.conf \
  # && sed -i "s|;*listen\s*=\s*/||g" /etc/php/php-fpm.conf \
  # && sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php/php.ini \
  # && sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php/php.ini \
  # && sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php/php.ini \
  # && sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php/php.ini \
  # && sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php/php.ini \
  # && sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php/php.ini \

ADD files/supervisord.conf /etc/supervisord.conf
# ADD files/nginx.conf /etc/nginx/nginx.conf

ADD files/instantclient.zip /opt/
# RUN unzip /opt/instantclient.zip -d /opt ; rm  /opt/instantclient.zip
# RUN ln -s /opt/instantclient/libclntsh.so.12.1 /opt/instantclient/libclntsh.so \
#   && ln -s /opt/instantclient/libocci.so.12.1 /opt/instantclient/libocci.so



VOLUME ["/var/www/application"]

EXPOSE 80 443

RUN supervisorctl start php-fpm
RUN supervisorctl start nginx

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]