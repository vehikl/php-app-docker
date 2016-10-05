COMPOSE_PROJECT_NAME := vehikl
COMPOSE_OPTS := "-p ${COMPOSE_PROJECT_NAME}"
NGINX_CONTAINER := "${COMPOSE_PROJECT_NAME}_nginx_1"
REDIS_CONTAINER := "${COMPOSE_PROJECT_NAME}_redis-server_1"
MYSQL_CONTAINER := "${COMPOSE_PROJECT_NAME}_mysql_1"
PHP_CONTAINER := "${COMPOSE_PROJECT_NAME}_php-fpm_1"
RABBIT_CONTAINER := "${COMPOSE_PROJECT_NAME}_rabbitmq_1"

## PHP Commands
composer_install: ## Install composer dependencies.
	@docker exec ${NGINX_CONTAINER} bash -c "cd /src && composer install --no-interaction"

## Laravel Commands
tail_logs: ## Tail Laravel logs.
	@docker exec -it ${NGINX_CONTAINER} tail -F /src/storage/logs/*

env_init: ## Copy sample environment file if an environemnt file doesn't already exist.
	@docker exec ${NGINX_CONTAINER} bash -c "cd /src && (cp -n .env.example .env || true)"

## Container Commands
shell: ## Open a shell in the app container.
	@docker exec -it ${NGINX_CONTAINER} /bin/bash

mysql: ## Open a psql instance in the postgres container.
	@docker exec -it ${MYSQL_CONTAINER} su -c "mysql" mysql

redis-cli: ## Open a redis-cli instance in the redis container.
	@docker exec -it ${REDIS_CONTAINER} /usr/local/bin/redis-cli

## Docker Commands
docker_clean: ## Remove exited docker containers and dangling images.
	@docker rm $$(docker ps -aq 2>/dev/null) 2>/dev/null || true
	@docker rm -v $$(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null || true
	@docker rmi $$(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null || true

halt: ## Stop running containers.
	@docker-compose ${COMPOSE_OPTS} stop

clean: ## Stop and remove running containers, and locally built images.
	@make halt
	@docker-compose ${COMPOSE_OPTS} rm -f
	@docker rmi ${COMPOSE_PROJECT_NAME}_nginx 2>/dev/null || true
	@docker rmi ${COMPOSE_PROJECT_NAME}_redis-server 2>/dev/null || true
	@docker rmi ${COMPOSE_PROJECT_NAME}_mysql 2>/dev/null || true
	@docker rmi ${COMPOSE_PROJECT_NAME}_php-fpm 2>/dev/null || true
	@docker rmi ${COMPOSE_PROJECT_NAME}_rabbitmq 2>/dev/null || true
	@make docker_clean

build: ## Force rebuild of all containers
	@docker-compose ${COMPOSE_OPTS} build

up:
	docker-compose ${COMPOSE_OPTS} up -d

.PHONY: help

help_markdown:
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "## `make %s`\n\n%s\n\n", $1, $2}'

help: # Print out target list.
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
