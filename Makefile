#******************************************************************************#
#	FEATURES
#******************************************************************************#

NC	:= \e[0m
BOLD	:= \e[1m
BLINK	:= \e[5m

RED	:= \e[31m
PO	:= \e[38;2;255;178;127m
PY	:= \e[38;2;255;234;150m
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

all:	up

setup:
		@mkdir -p $(DATA_PATH)/mariadb/
		@mkdir -p $(DATA_PATH)/wordpress/

up:	setup
		@$(DOCKER_COMPOSE) up -d --build
		@printf "\n$(BOLD)$(PG)[up]$(NC)$(PG) Built all containers' image in the background\n\n$(NC)"

down:
		@$(DOCKER_COMPOSE) down --volumes
		@printf "\n$(BOLD)$(PO)[down -v]$(NC)$(PO) Stopped and removed containers, networks and volumes$(NC)\n\n"

fclean:	down
		@docker system prune --all --force
		@sudo rm -rf $(DATA_PATH)/mariadb/*
		@sudo rm -rf $(DATA_PATH)/wordpress/*
		@printf "\n$(BOLD)$(RED)[system prune -a]:$(NC)$(RED) All unused images, containers, and volumes have been purged from the system$(NC)\n\n"

re:	fclean all

# Show container status
ps:
		@$(DOCKER_COMPOSE) ps

# -f, --follow: Follow log output
logs:
		@$(DOCKER_COMPOSE) logs -f

.PHONY:	all setup up down fclean re ps logs
