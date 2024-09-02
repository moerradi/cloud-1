FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install nginx -y
RUN mkdir /var/ssl
COPY ./keys /var/ssl
COPY ./main.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/main.conf /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
