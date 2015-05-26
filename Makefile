.PHONY: all default build-images fetch clean test serve build release export shell

DOCKER_IP=$(shell python -c "import urlparse ; print urlparse.urlparse('$(DOCKER_HOST)').hostname or ''")
HUGO_BASE_URL=$(shell test -z "$(DOCKER_IP)" && echo localhost || echo "$(DOCKER_IP)")
HUGO_BIND_IP=0.0.0.0
DATA_CONTAINER_CMD=docker-compose ps | tail -n +3 | grep data | awk '{print $$1;}'

default: build-images build

build-images:
	docker-compose build

fetch:
	docker-compose up fetch

clean:
	docker-compose rm -fv

test:
	HUGO_BIND_IP=$(HUGO_BIND_IP) HUGO_BASE_URL=$(HUGO_BASE_URL) docker-compose up test

serve: fetch
	HUGO_BIND_IP=$(HUGO_BIND_IP) HUGO_BASE_URL=$(HUGO_BASE_URL) docker-compose up serve

build: fetch
	docker-compose up build

release: build
	docker-compose up upload

export: build
	docker cp $$($(DATA_CONTAINER_CMD)):/public - | gzip > docs-docker-com.tar.gz

shell: build
	docker-compose run --rm build /bin/bash
