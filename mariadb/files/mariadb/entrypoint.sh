#!/bin/bash

if [ -d "/run/mysqld" ]; then
	echo "[i] mysqld run folder already present, skipping creation"
else
	echo "[i] mysqld run folder not found, creating...."
	mkdir -p /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
	echo "[i] MariaDB data directory already present, skipping creation"
else
	echo "[i] MariaDB data directory not found, creating initial DBs"

	mariadb-install-db --ldata=/var/lib/mysql > /dev/null

	if [ "$MARIADB_ROOT_PASSWORD" = "" ]; then
		MARIADB_ROOT_PASSWORD=`pwgen 16 1`
		echo "[i] MARIADB root Password: $MARIADB_ROOT_PASSWORD"
	fi

	MARIADB_DATABASE=${MARIADB_DATABASE:-""}
	MARIADB_USER=${MARIADB_USER:-""}
	MARIADB_PASSWORD=${MARIADB_PASSWORD:-""}

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
	    return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES ;
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MARIADB_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF

	if [ "$MARIADB_DATABASE" != "" ]; then
	    echo "[i] Creating database: $MARIADB_DATABASE"
		if [ "$MARIADB_CHARSET" != "" ] && [ "$MARIADB_COLLATE" != "" ]; then
			echo "[i] with character set [$MARIADB_CHARSET] and collation [$MARIADB_COLLATE]"
			echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET $MARIADB_CHARSET COLLATE $MARIADB_COLLATE;" >> $tfile
		else
			echo "[i] with character set: 'utf8' and collation: 'utf8_general_ci'"
			echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
		fi

	 if [ "$MARIADB_USER" != "" ]; then
		echo "[i] Creating user: $MARIADB_USER"
		echo "GRANT ALL ON \`$MARIADB_DATABASE\`.* to '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';" >> $tfile
	    fi
	fi

	mariadbd --bootstrap --verbose=0 --skip-networking=0 < $tfile
	rm -f $tfile
	echo
	echo 'MariaDB init process done. Ready for start up.'
	echo
fi

exec "$@"
