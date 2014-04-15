# docker-piwik-mariadb

A Dockerfile that produces a container that will run [Piwik][piwik] and [MariaDB][mariadb] 5.5,
a drop-in replacement for MySQL.

[piwik]: https://piwik.org/
[mariadb]: https://mariadb.org/

## Image Creation

This example creates the image with the tag `myusername/piwik`, but you can
change this to use your own username.

```
$ docker build -t="myusername/piwik" .
```

Alternately, you can run the following if you have *make* installed...

```
$ make
```

You can also specify a custom docker username like so:

```
$ make DOCKER_USER=myusername
```

## Container Creation / Running

The MariaDB server is configured to store data in `/data` inside the container.
You can map the container's `/data` volume to a volume on the host so the data
becomes independant of the running container.

This example uses `/tmp/mariadb` to store the MariaDB data, but you can modify
this to your needs.

When the container runs, it creates a superuser with a random password.  You
can set the username and password for the superuser by setting the container's
environment variables.  This lets you discover the username and password of the
superuser from within a linked container or from the output of `docker inspect
mariadb`.

``` shell
$ mkdir -p /tmp/mariadb
$ docker run -d -name="piwik" \
             -v /tmp/mariadb:/data \
             -e USER="super" \
             -e PASS="$(pwgen -s -1 16)" \
             myusername/piwik
```

Alternately, you can run the following if you have *make* installed...

``` shell
$ make run
```

You can also specify a custom data directory, and the superuser username and
password on the host like so:

``` shell
$ sudo mkdir -p /srv/docker/mariadb
$ make run DATA_DIR=/srv/docker/mariadb \
           USER=super \
           PASS=$(pwgen -s -1 16)
```

## Connecting to the Database

As part of the startup for MariaDB, the container will generate a random
password for the superuser.  To view the login in run `docker logs
<container_name>` like so:

``` shell
$ docker logs mariadb
MARIADB_USER=super
MARIADB_PASS=FzNQiroBkTHLX7y4
MARIADB_DATA_DIR=/data
Starting MariaDB...
140103 20:33:49 mysqld_safe Logging to '/data/mysql.log'.
140103 20:33:49 mysqld_safe Starting mysqld daemon with databases from /data
```

The MARIADB_USER and MARIADB_PASS fields will be needed when configuring Piwik the first time.
