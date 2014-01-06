# Substitute your own docker index username, if you like.
DOCKER_USER=paintedfox

# Change this to suit your needs.
NAME:=mariadb
USER:=super
PASS:=$(shell pwgen -s -1 16)
DATA_DIR:=/tmp/mariadb
PORT:=127.0.0.1:3306

RUNNING_MARIADB:=$(shell docker ps | grep mariadb | cut -f 1 -d ' ')
ALL_MARIADB:=$(shell docker ps -a | grep mariadb | cut -f 1 -d ' ')
DOCKER_RUN_COMMON=-name="$(NAME)" -p $(PORT):3306 -v $(DATA_DIR):/data -e USER="$(USER)" -e PASS="$(PASS)" $(DOCKER_USER)/mariadb

all: build

build:
	docker build -t="$(DOCKER_USER)/mariadb" .

run: clean
	mkdir -p $(DATA_DIR)
	docker run -d $(DOCKER_RUN_COMMON)

bash: clean
	mkdir -p $(DATA_DIR)
	docker run -entrypoint="/bin/bash" -t -i $(DOCKER_RUN_COMMON)

# Removes existing containers.
clean:
ifneq ($(strip $(RUNNING_MARIADB)),)
	docker stop $(RUNNING_MARIADB)
endif
ifneq ($(strip $(ALL_MARIADB)),)
	docker rm $(ALL_MARIADB)
endif

# Destroys the data directory.
deepclean: clean
	sudo rm -rf $(DATA_DIR)
