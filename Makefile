DATA_DIR=/home/hskrzypi/data
MARIADB_DIR=$(DATA_DIR)/mariadb_database
WORDPRESS_DIR=$(DATA_DIR)/wordpress_database

COMPOSE_FILE=srcs/docker-compose.yml

all: mariadb_data wordpress_data build up
	@echo "...And we are done."

mariadb_data:
	@mkdir -p $(MARIADB_DIR)

wordpress_data:
	@mkdir -p $(WORDPRESS_DIR)

build:
	@echo "Building Docker images..."
	@docker compose -f $(COMPOSE_FILE) build

up:
	@echo "Running containers..."
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@echo "Stopping containers..."
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@echo "Removing containers, images and volumes..."
	@docker compose -f $(COMPOSE_FILE) down --rmi all -v 

fclean: clean
	@echo "Removing data directories..."
	@sudo rm -rf $(DATA_DIR)
	@docker system prune -f --volumes

re: fclean all

.PHONY: all clean fclean re up down mariadb_data wordpress_data build

