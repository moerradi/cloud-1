FROM debian:bookworm

#update and upgrade
RUN apt-get update && apt-get upgrade -y
#intsall php
RUN apt-get install -y php8.2-cli php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip
# remove old config 
RUN rm -rf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN service php8.2-fpm restart
EXPOSE 9000

CMD ["php-fpm8.2", "-F", "-R"]
