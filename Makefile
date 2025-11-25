# -------------------------------
# VARIABLES
# -------------------------------
compose= ./srcs/docker-compose.yml
data_mariadb= /home/loay1/data/mariadb
data_wordpress= /home/loay1/data/wordpress

# -------------------------------
# TARGETS
# -------------------------------

# Start containers (build if needed)
up:
	@mkdir -p $(data_mariadb) $(data_wordpress)
	@docker-compose -f $(compose) up -d --build

# Stop containers (leave them)
stop:
	@docker-compose -f $(compose) stop

# Stop and remove containers
down:
	@docker-compose -f $(compose) down

# Stop + start containers
restart: down up

# Rebuild containers from scratch
rebuild:
	@docker-compose -f $(compose) up -d --build --force-recreate

# Show logs (follow)
logs:
	@docker-compose -f $(compose) logs -f

# Show running containers
ps:
	@docker-compose -f $(compose) ps

# Clean containers + volumes + orphans
clean:
	@docker-compose -f $(compose) down --volumes --remove-orphans

# Full clean: remove containers, volumes, images, system prune, and data
fclean: clean
	@docker rmi -f $$(docker images -a -q) 2>/dev/null || true
	@docker system prune -f --volumes
	@rm -rf /home/loay1/data/*

# Prune only unused docker resources
prune:
	@docker system prune -f

re: fclean up

# -------------------------------
# PHONY
# -------------------------------
.PHONY: up down stop restart rebuild logs ps clean fclean prune re
