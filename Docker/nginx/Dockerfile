FROM nginx

RUN apt-get update \
    && apt-get install -y vim wget curl software-properties-common python-software-properties \
    && echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list \
    && wget https://www.dotdeb.org/dotdeb.gpg \
    && apt-key add dotdeb.gpg \
    && apt-get update && apt-get install -y \
        php7.0-common \
        php7.0-cli

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

ADD nginx.conf /etc/nginx/
ADD app.conf /etc/nginx/conf.d/default.conf

#ADD letsencrypt.sh ./letsencrypt.sh
#RUN /bin/bash -c "source ./letsencrypt.sh"
RUN echo "upstream php-upstream { server php-fpm:9000; }" > /etc/nginx/conf.d/upstream.conf

EXPOSE 80
EXPOSE 443
