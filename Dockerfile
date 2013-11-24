# MariaDB (https://mariadb.org/)

FROM ubuntu:precise
MAINTAINER Ryan Seto <ryanseto@yak.net>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
        apt-get update && \
        apt-get upgrade

# Ensure UTF-8
RUN apt-get update
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Install MariaDB from repository.
RUN apt-get -y install python-software-properties && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu precise main' && \
    apt-get update && \
    apt-get install -y mariadb-server && \
    /etc/init.d/mysql stop

# Create the superuser
ENV MARIADB_USER docker
ENV MARIADB_PASS docker
RUN /etc/init.d/mysql start && \
    mysql -u root -e \
    "CREATE USER '$MARIADB_USER'@'localhost' IDENTIFIED BY '$MARIADB_PASS'; GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'localhost' WITH GRANT OPTION; CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASS'; GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'%' WITH GRANT OPTION;"
    /etc/init.d/mysql stop

# Decouple our data from our container.
VOLUME ["/data"]

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/mysql/my.cnf

# Configure MariaDB to listen on any address.
RUN sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

EXPOSE 3306
ADD start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
