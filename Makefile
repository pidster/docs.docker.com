.PHONY: all default build-images fetch clean clean-bucket test serve build release export shell

PROJECT_NAME ?= docsdockercom
DOCKER_COMPOSE := docker-compose-1.5.0rc1 -p $(PROJECT_NAME)
export IMAGE_TAG ?= $(shell git rev-parse --short HEAD)
DOCKER_IMAGE := docsdockercom:$(IMAGE_TAG)
DOCKER_IP = $(shell python -c "import urlparse ; print urlparse.urlparse('$(DOCKER_HOST)').hostname or ''")
HUGO_BASE_URL = $(shell test -z "$(DOCKER_IP)" && echo localhost || echo "$(DOCKER_IP)")
HUGO_BIND_IP = 0.0.0.0
DATA_CONTAINER_CMD = $(DOCKER_COMPOSE) ps -q data | head -n 1
RELEASE_LATEST ?=

ifndef RELEASE_LATEST
	DOCS_VERSION = $(shell cat VERSION | head -n1 | awk '{print $$1}')
else
	DOCS_VERSION =
endif

default: build-images build

build-images:
	docker build -t $(DOCKER_IMAGE) .

fetch:
	$(DOCKER_COMPOSE) run fetch

clean:
	$(DOCKER_COMPOSE) rm -fv ; \
	docker rmi $$( docker images | grep -E '^$(PROJECT_NAME)_' | awk '{print $$1}' ) 2>/dev/null ||:

clean-bucket:
	RM_OLDER_THAN="$(RM_OLDER_THAN)" $(DOCKER_COMPOSE) run --rm cleanup

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
