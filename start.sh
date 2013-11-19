#!/bin/bash
# Starts up MariaDB within the container.

DATADIR="/data"

# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
  echo "Initializing MariaDB at $DATADIR"
  chown -R mysql $DATADIR

  # Copy the data that we generated within the container to the empty DATADIR.
  cp -R /var/lib/mysql/* $DATADIR
fi

# Ensure mysql owns the DATADIR
chown -R mysql $DATADIR
# Ensure we have the right permissions set on the DATADIR
chmod -R 700 $DATADIR

/usr/bin/mysqld_safe
