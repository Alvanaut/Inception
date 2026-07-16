NAME    = inception

COMPOSE = srcs/docker-compose.yml

DATA    = /home/$(USER)/data

all: up

up:

	@mkdir -p $(DATA)/mariadb $(DATA)/wordpress

	@docker compose -f $(COMPOSE) up -d --build

down:

	@docker compose -f $(COMPOSE) down

stop:

	@docker compose -f $(COMPOSE) stop

start:

	@docker compose -f $(COMPOSE) start

clean: down

	@docker system prune -af

fclean: clean

	@sudo rm -rf $(DATA)/mariadb/* $(DATA)/wordpress/*

	@docker volume prune -f

re: fclean all

.PHONY: all up down stop start clean fclean re

