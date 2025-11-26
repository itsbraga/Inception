#******************************************************************************#
#	FEATURES
#******************************************************************************#

NC	:= \e[0m
BOLD	:= \e[1m
BLINK	:= \e[5m

RED	:= \e[31m
PO	:= \e[38;2;255;178;127m
PY	:= \e[38;2;255;234;150m
PP	:= \e[38;2;211;211;255m
BLUE	:= \e[34m
CYAN	:= \e[36m
PG	:= \e[38;2;173;235;179m
HPINK	:= \e[38;2;255;105;180m

#******************************************************************************#
#	COMPILATION
#******************************************************************************#

USER			= annabrag
DOCKER_COMPOSE_F	= srcs/docker-compose.yml
DOCKER_COMPOSE		= docker compose -f $(DOCKER_COMPOSE_F)
DATA_PATH		= /home/$(USER)/data

#******************************************************************************#
#	RULES
#******************************************************************************#

all: up

setup:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

up: setup
	@$(DOCKER_COMPOSE) up -d --build
	@printf "\n$(BOLD)$(PG)[up]$(NC)$(PG) Built all containers' image in the background$(NC)\n\n"

down:
	@$(DOCKER_COMPOSE) down
	@printf "\n$(BOLD)$(PY)[down]$(NC)$(PY) Stopped containers$(NC)\n\n"

clean:
	@$(DOCKER_COMPOSE) down --volumes
	@printf "\n$(BOLD)$(PO)[clean]$(NC)$(PO) Stopped and cleaned containers, project network and volumes$(NC)\n\n"

fclean: clean
	@docker image rm -f mariadb:1.0
	@docker image rm -f wordpress:1.0
	@docker image rm -f nginx:1.0
	@docker volume rm -f inception_mariadb-data
	@docker volume rm -f inception_wordpress-data
	@docker builder prune --all --force
	@rm -rf $(DATA_PATH)/mariadb/*
	@rm -rf $(DATA_PATH)/wordpress/*
	@printf "\n$(BOLD)$(RED)[fclean]$(NC)$(RED) All unused images, containers, and volumes have been purged from the system$(NC)\n\n"

re: fclean
	@make --no-print-directory all

# Show container status
ps:
	@printf "$(BOLD)$(PP)=== Infrastructure Status ===$(NC)\n\n"
	@$(DOCKER_COMPOSE) ps mariadb wordpress nginx

# -f, --follow: Follow log output
logs:
	@$(DOCKER_COMPOSE) logs -f

.PHONY:	all setup up down fclean re ps logs
