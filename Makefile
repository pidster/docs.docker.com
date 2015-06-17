.PHONY: all default build-images fetch clean test serve build release export shell

PROJECT_NAME ?= docsdockercom
DOCKER_COMPOSE := docker-compose -p $(PROJECT_NAME)
DOCKER_IP = $(shell python -c "import urlparse ; print urlparse.urlparse('$(DOCKER_HOST)').hostname or ''")
HUGO_BASE_URL = $(shell test -z "$(DOCKER_IP)" && echo localhost || echo "$(DOCKER_IP)")
HUGO_BIND_IP = 0.0.0.0
DATA_CONTAINER_CMD = $(DOCKER_COMPOSE) ps -q data | head -n 1
RELEASE_LATEST ?=

ifndef RELEASE_LATEST
	DOCS_VERSION = $(shell cat VERSION)
else
	DOCS_VERSION =
endif

default: build-images build

build-images:
	$(DOCKER_COMPOSE) build ; \
	CONTAINER_ID=$$( $(DOCKER_COMPOSE) run -d fetch true) ; \
	until IMAGE_NAME=$$( docker inspect -f "{{ .Config.Image }}" "$$CONTAINER_ID" ) && [ -n "$$IMAGE_NAME" ] ; do echo "sleep $$CONTAINER_ID" ; sleep 1; done ; \
	docker tag "$$IMAGE_NAME" "$(PROJECT_NAME):latest" ; \
	docker rm -f "$$CONTAINER_ID" >/dev/null

fetch:
	$(DOCKER_COMPOSE) up fetch

clean:
	$(DOCKER_COMPOSE) rm -fv ; \
	docker rmi $$( docker images | grep -E '^$(PROJECT_NAME)_' | awk '{print $$1}' ) 2>/dev/null ||:

serve: fetch
	HUGO_BIND_IP=$(HUGO_BIND_IP) HUGO_BASE_URL=$(HUGO_BASE_URL) $(DOCKER_COMPOSE) up serve

build: fetch
	DOCS_VERSION=$(DOCS_VERSION) $(DOCKER_COMPOSE) up build

release: build
	CLEAN=$(DOCS_VERSION) $(DOCKER_COMPOSE) up upload

export: build
	docker cp $$($(DATA_CONTAINER_CMD)):/public - | gzip > docs-docker-com.tar.gz

shell: build
	$(DOCKER_COMPOSE) run --rm build /bin/bash
