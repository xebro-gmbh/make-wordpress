#--------------------------
# xebro GmbH - wordpress - 1.0.0
#--------------------------

.PHONY:

XO_WORDPRESS_PORT ?= 8080

WORDPRESS_DIR := $(patsubst $(XO_ROOT_DIR)/%,./%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
WORDPRESS_DIR_ABS := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

WORDPRESS := $(notdir $(patsubst %/,%,$(WORDPRESS_DIR)))

DOCKER_WORDPRESS=${DOCKER_COMPOSE} exec wordpress
DOCKER_WPCLI=${DOCKER_COMPOSE} run --rm wpcli

wordpress.help:
	$(call add_help,${WORDPRESS_DIR}Makefile,"WordPress")

wordpress.logs: ## Show wordpress container logs
	@${DOCKER_COMPOSE} logs -f wordpress

wordpress.bash: ## Open bash inside the wordpress container
	@${DOCKER_WORDPRESS} bash

wordpress.wp: ## Run a wp-cli command, e.g. make wordpress.wp cmd="plugin list"
	@${DOCKER_WPCLI} $${cmd}

wordpress.install:
	$(call headline,"Installing WordPress")
	$(call ensure_env_vars,".env","${WORDPRESS_DIR}config/.env")
	$(call seed_env_vars,".env","${WORDPRESS_DIR}config/.env.seed")
	$(call ensure_lines,.gitignore,${WORDPRESS_DIR}config/.gitignore)
	@mkdir -p ${XO_ROOT_DIR}/${XO_WORDPRESS_ROOT}
	@mkdir -p ${XO_ROOT_DIR}/${XO_WORDPRESS_THEME_DIR}

wordpress.setup: ## Install WordPress core (idempotent) and activate the project theme
	$(call target_name,$@)
	@${DOCKER_COMPOSE} up -d --wait wordpress
	@${DOCKER_WPCLI} core is-installed 2>/dev/null || ${DOCKER_WPCLI} core install \
		--url="http://localhost:${XO_WORDPRESS_PORT}" \
		--title="$${WORDPRESS_TITLE}" \
		--admin_user="$${WORDPRESS_ADMIN_USER}" \
		--admin_password="$${WORDPRESS_ADMIN_PASSWORD}" \
		--admin_email="$${WORDPRESS_ADMIN_EMAIL}" \
		--skip-email
	@${DOCKER_WPCLI} theme activate ${XO_WORDPRESS_THEME}

wordpress.restart: ## Restart wordpress container
	@${DOCKER_COMPOSE} restart wordpress --no-deps

wordpress.debug: ## Print WordPress component environment
	@$(call headline,"DEBUGGING WORDPRESS")
	@printf "${Purple}WORDPRESS_DIR: ${Yellow} ${WORDPRESS_DIR}\n"
	@printf "${Purple}XO_WORDPRESS_PORT: ${Yellow} ${XO_WORDPRESS_PORT}\n"
	@printf "${Purple}XO_WORDPRESS_ROOT: ${Yellow} ${XO_WORDPRESS_ROOT}\n"
	@printf "${Purple}XO_WORDPRESS_THEME: ${Yellow} ${XO_WORDPRESS_THEME}\n"
	@printf "${Purple}XO_WORDPRESS_THEME_DIR: ${Yellow} ${XO_WORDPRESS_THEME_DIR}\n"

debug: wordpress.debug
help: wordpress.help
init: wordpress.setup
install: wordpress.install
restart: wordpress.restart
