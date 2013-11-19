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

# delete anonymous users, set password "root" for user root,
# allow remote access for user root, delete database "test"
# borrowed from: https://github.com/mattes/docker-mysql/blob/master/Dockerfile
RUN /etc/init.d/mysql start && mysql -S /var/run/mysqld/mysqld.sock -u root -e "DELETE FROM mysql.user WHERE User = ''; UPDATE mysql.user SET Password=PASSWORD('root') WHERE User = 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root'; DROP DATABASE IF EXISTS test; FLUSH PRIVILEGES;"; /etc/init.d/mysql stop

# Decouple our data from our container.
VOLUME ["/data"]

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/mysql/my.cnf

# Configure MariaDB to listen on any address.
RUN sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

ADD start.sh /start.sh
RUN chmod +x /start.sh
#ENTRYPOINT ["/start.sh"]
