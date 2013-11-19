# docker-mariadb

A Dockerfile that produces a container that will run [MariaDB][mariadb] 5.5, a drop-in replacement for MySQL.

[mariadb]: https://mariadb.org/

## Image Creation

```
$ sudo docker build -t="paintedfox/mariadb" .
```

## Container Creation / Running

The MariaDB server is configured to store data in `/data` inside the container.  You can map the container's `/data` volume to a volume on the host so the data becomes independant of the running container.

This example uses `/tmp/mariadb` to store the MariaDB data, but you can modify this to your needs.

```
$ mkdir -p /tmp/mariadb
$ sudo docker run -p 5432 -v /tmp/mariadb:/data paintedfox/mariadb
```
