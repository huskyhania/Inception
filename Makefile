DATA_DIR=/home/hskrzypi/data
MARIADB_DIR=$(DATA_DIR)/mariadb
WORDPRESS_DIR=$(DATA_DIR)/wordpress

COMPOSE_FILE=srcs/docker-compose.yml

all: mariadb_data wordpress_data
	@echo "Creating MariaDB data directory..."
	@mkdir -p $(MARIADB_DIR)
	@echo "Creating WordPress data directory..."
	@mkdir -p $(WORDPRESS_DIR)
	@echo "Building and running containers..."
	@$(MAKE) images
	@$(MAKE) up
	@echo "...And we are done."

images:
	@echo "Building Docker images..."
	@docker compose -f $(COMPOSE_FILE) build

up:
	@echo "Running containers..."
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@echo "Stopping containers..."
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@echo "Removing containes, images and volumes..."
	@docker compose -f $(COMPOSE_FILE) down --rmi all -v 

fclean: clean
	@echo "Removing data directories..."
	@sudo rm -rf $(DATA_DIR)
	@docker system prune -f --volumes

re: fclean all

.PHONY: all clean fclean re up down mariadb_data wordpress_data images

