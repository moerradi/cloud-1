FROM debian:bookworm

#install mariadb and dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install curl software-properties-common dirmngr gnupg2 pwgen -y
RUN curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
RUN chmod +x mariadb_repo_setup
RUN bash mariadb_repo_setup --os-type=debian --os-version=bookworm --mariadb-server-version=11.4
RUN apt-get install -y mariadb-server mariadb-backup
# remove old sql config
RUN rm -rf /etc/mysql/mariadb.conf.d/50-server.cnf
# add new sql config
COPY mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# remove old sql data
RUN rm -rf /var/lib/mysql
# recreate sql data
RUN mkdir /var/lib/mysql
# copy setup script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]
EXPOSE 3306

CMD ["mariadbd"]
