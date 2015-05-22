.PHONY: all default build-images fetch clean test serve build release export shell

DATA_CONTAINER := $(shell docker-compose ps | tail -n +3 | grep data | awk '{print $$1;}' )

default: build-images build

build-images:
	docker-compose build

fetch:
	docker-compose up fetch

clean:
	docker-compose rm -fv

test:
	echo "not implemented"

serve: fetch
	docker-compose up serve

build: fetch
	docker-compose up build

release: build
	docker-compose up upload

export: build
	docker cp $(DATA_CONTAINER):/public - | gzip > docs-docker-com.tar.gz

shell: build
	docker-compose run --rm build /bin/bash
