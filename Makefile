.PHONY: all default build-images fetch clean clean-bucket test serve build release export shell

PROJECT_NAME ?= docsdockercom
DOCKER_COMPOSE := docker-compose -p $(PROJECT_NAME)
DOCKER_IP = $(shell python -c "import urlparse ; print urlparse.urlparse('$(DOCKER_HOST)').hostname or ''")
ifndef HUGO_BASE_URL
	HUGO_BASE_URL_AUTO = 1
	HUGO_BASE_URL = $(shell test -z "$(DOCKER_IP)" && echo localhost || echo "$(DOCKER_IP)")
else
	HUGO_BASE_URL ?= $(HUGO_BASE_URL)
endif
DATA_CONTAINER_CMD = $(DOCKER_COMPOSE) ps -q data | head -n 1
DOCS_VERSION = $(shell cat VERSION | head -n1 | awk '{print $$1}')

default: build-images build

build-images:
	$(DOCKER_COMPOSE) build ; \
	CONTAINER_ID=$$( $(DOCKER_COMPOSE) run -d fetch true) ; \
	until IMAGE_NAME=$$( docker inspect -f "{{ .Config.Image }}" "$$CONTAINER_ID" ) && [ -n "$$IMAGE_NAME" ] ; do echo "sleep $$CONTAINER_ID" ; sleep 1; done ; \
	docker tag -f "$$IMAGE_NAME" "$(PROJECT_NAME):latest" ; \
	docker rm -f "$$CONTAINER_ID" >/dev/null

fetch:
	$(DOCKER_COMPOSE) up fetch

clean:
	$(DOCKER_COMPOSE) rm -fv ; \
	docker rmi $$( docker images | grep -E '^$(PROJECT_NAME)_' | awk '{print $$1}' ) 2>/dev/null ||:

serve: fetch
	HUGO_BASE_URL=$(DOCKER_IP) $(DOCKER_COMPOSE) up serve

build: fetch
	HUGO_BASE_URL=$(HUGO_BASE_URL) DOCS_VERSION=$(DOCS_VERSION) $(DOCKER_COMPOSE) up build

release: build
	[ -n "$(HUGO_BASE_URL_AUTO)" ] && echo "Set HUGO_BASE_URL to release" && exit 1 ; \
	LATEST=$(LATEST) HUGO_BASE_URL=$(HUGO_BASE_URL) DOCS_VERSION=$(DOCS_VERSION) $(DOCKER_COMPOSE) up upload

export: build
	docker cp $$($(DATA_CONTAINER_CMD)):/public - | gzip > docs-docker-com.tar.gz

shell: build
	$(DOCKER_COMPOSE) run --rm build /bin/bash
