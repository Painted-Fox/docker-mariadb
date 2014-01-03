#!/bin/bash
# Starts up MariaDB within the container.

# Stop on error
set -e

SUPER_USER=super
SUPER_PASS=$(pwgen -s -1 16)
DATADIR=/data

# Echo out info to later obtain by running `docker logs container_name`
echo "MARIADB_SUPER_USER=$SUPER_USER"
echo "MARIADB_SUPER_PASS=$SUPER_PASS"
echo "MARIADB_DATA_DIR=$DATADIR"

# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
    echo "Initializing MariaDB at $DATADIR"
    # Copy the data that we generated within the container to the empty DATADIR.
    cp -R /var/lib/mysql/* $DATADIR
fi

# Ensure mysql owns the DATADIR
chown -R mysql $DATADIR
chown root $DATADIR/debian*.flag

/etc/init.d/mysql start
sleep 1

# The password for 'debian-sys-maint'@'localhost' is auto generated.
# The database inside of DATADIR may not have been generated with this password.
# So, we need to set this for our database to be portable.
echo "Setting password for the 'debian-sys-maint'@'localhost' user"
DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')
mysql -u root -e \
    "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS';"

# Create the superuser.
mysql -u root -e "$(cat << EOF
    DELETE FROM mysql.user WHERE user = '$SUPER_USER';
    CREATE USER '$SUPER_USER'@'localhost' IDENTIFIED BY '$SUPER_PASS';
    GRANT ALL PRIVILEGES ON *.* TO '$SUPER_USER'@'localhost' WITH GRANT OPTION;
    CREATE USER '$SUPER_USER'@'%' IDENTIFIED BY '$SUPER_PASS';
    GRANT ALL PRIVILEGES ON *.* TO '$SUPER_USER'@'%' WITH GRANT OPTION;
EOF
)"

/etc/init.d/mysql stop

# Start MariaDB
echo "Starting MariaDB..."
/usr/bin/mysqld_safe --skip-syslog --log-error=$DATADIR/mysql.err
