#******************************************************************************#
#	FEATURES
#******************************************************************************#

RESET		:=	\e[0m
BOLD		:=	\e[1m
BLINK		:=	\e[5m

RED			:=	\e[31m
P_ORANGE	:=	\e[38;2;255;178;127m
YELLOW		:=	\e[38;2;255;234;150m
BLUE		:=	\e[34m
CYAN		:=	\e[36m
P_GREEN		:=	\e[38;2;173;235;179m
HOT_PINK	:=	\e[38;2;255;105;180m

#******************************************************************************#
#	COMPILATION
#******************************************************************************#

DOCKER_COMPOSE_F	=	srcs/docker-compose.yml
DOCKER_COMPOSE		=	docker compose -f $(DOCKER_COMPOSE_F)
DATA_PATH			=	/home/annabrag/data

#******************************************************************************#
#	RULES
#******************************************************************************#

all:	up

setup:
		@mkdir -p $(DATA_PATH)/mariadb
		@mkdir -p $(DATA_PATH)/wordpress

#	-d, --detach: Run containers in the background
#	--build: Build images before starting containers
up:		setup
		@$(DOCKER_COMPOSE) up --d --build
		@printf "$(BOLD)$(P_GREEN)[up] $(RESET)Built and started containers\n\n"

down:
		@$(DOCKER_COMPOSE) down
		@printf "$(BOLD)$(P_ORANGE)[down] $(RESET)Stopped containers\n\n"

clean:
		@$(DOCKER_COMPOSE) down --volumes
		@printf "$(BOLD)$(RED)[clean] $(RESET)Stopped and removed containers, networks, and volumes\n\n"

#	-a, --all: Remove all unused images not just dangling ones
fclean:	clean
		@docker system prune --all
		@sudo rm -rf $(DATA_PATH)/mariadb/*
		@sudo rm -rf $(DATA_PATH)/wordpress/*
		@printf "$(BOLD)$(CYAN)[fclean]: $(RESET)Full clean completed (including images and data)!\n\n"

re:		fclean all

#	Show container status
ps:
		@$(DOCKER_COMPOSE) ps

#	-f, --follow: Follow log output
logs:
		@$(DOCKER_COMPOSE) logs -f

.PHONY:	all setup up down clean fclean re ps logs
