.PHONY: all default build-images fetch clean clean-bucket test serve build release export shell

PROJECT_NAME ?= docsdockercom
DOCKER_COMPOSE := docker-compose-1.5.0rc1 -p $(PROJECT_NAME)
export IMAGE_TAG ?= $(shell git rev-parse --abbrev-ref HEAD)
DOCKER_IMAGE := docsdockercom:$(IMAGE_TAG)
DOCKER_IP = $(shell python -c "import urlparse ; print urlparse.urlparse('$(DOCKER_HOST)').hostname or ''")
export HUGO_BASE_URL = $(shell test -z "$(DOCKER_IP)" && echo localhost || echo "$(DOCKER_IP)")
DATA_CONTAINER_CMD = $(DOCKER_COMPOSE) ps -q data | head -n 1
RELEASE_LATEST ?=

ifndef RELEASE_LATEST
	export DOCS_VERSION = $(shell cat VERSION | head -n1 | awk '{print $$1}')
else
	export DOCS_VERSION =
endif

default: build-images build

build-images:
	docker build -t $(DOCKER_IMAGE) .

fetch:
	$(DOCKER_COMPOSE) run --rm fetch

clean:
	docker rmi $(DOCKER_IMAGE)

clean-bucket:
	RM_OLDER_THAN="$(RM_OLDER_THAN)" $(DOCKER_COMPOSE) run --rm cleanup

serve: fetch
	$(DOCKER_COMPOSE) up serve

build: fetch
	$(DOCKER_COMPOSE) run --rm build

release: build
	CLEAN=$(DOCS_VERSION) $(DOCKER_COMPOSE) rm --rm upload

export: build
	docker cp $$($(DATA_CONTAINER_CMD)):/public - | gzip > docs-docker-com.tar.gz

shell: build
	$(DOCKER_COMPOSE) run --rm build /bin/bash

test:
	$(DOCKER_COMPOSE) up -d serve
	sleep 2
	$(DOCKER_COMPOSE) run --rm test bash
	$(DOCKER_COMPOSE) stop
	$(DOCKER_COMPOSE) rm -f serve

markdownlint:
	docker exec -it docsdockercom_serve_1 /usr/local/bin/markdownlint /docs/content/

htmllint:
	docker exec -it docsdockercom_serve_1 /usr/local/bin/linkcheck http://127.0.0.1:8000

all: clean build build-images serve

# Sven doesn't have docker-compose installed on some boxes, so use a compose container
compose:
	docker run --rm -it \
		-e GITHUB_USERNAME -e GITHUB_TOKEN \
		-v $(CURDIR):$(CURDIR) \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /usr/bin/docker-static:/usr/bin/docker \
		-w $(CURDIR) \
		--entrypoint bash \
			svendowideit/compose
