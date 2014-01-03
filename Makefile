DOCKER_USER=paintedfox

RUNNING_MARIADB:=$(shell docker ps | grep mariadb | cut -f 1 -d ' ')
ALL_MARIADB:=$(shell docker ps -a | grep mariadb | cut -f 1 -d ' ')
DOCKER_RUN_COMMON=-name="mariadb" -p 127.0.0.1:3306:3306 -v /tmp/mariadb:/data $(DOCKER_USER)/mariadb

all: build

build:
	docker build -t="$(DOCKER_USER)/mariadb" .

run: clean
	docker run -d $(DOCKER_RUN_COMMON)

bash: clean
	docker run -entrypoint="/bin/bash" -t -i $(DOCKER_RUN_COMMON)

clean:
	sudo rm -rf /tmp/mariadb
	mkdir -p /tmp/mariadb
ifneq ($(strip $(RUNNING_MARIADB)),)
	docker stop $(RUNNING_MARIADB)
endif
ifneq ($(strip $(ALL_MARIADB)),)
	docker rm $(ALL_MARIADB)
endif
