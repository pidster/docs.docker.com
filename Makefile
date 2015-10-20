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
ifndef GITHUB_USERNAME
	$(error GITHUB_USERNAME is undefined)
endif
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is undefined)
endif
	$(DOCKER_COMPOSE) run --rm fetch

clean:
	docker rmi $(DOCKER_IMAGE)

clean-bucket:
	RM_OLDER_THAN="$(RM_OLDER_THAN)" $(DOCKER_COMPOSE) run --rm cleanup

serve: fetch
	$(DOCKER_COMPOSE) up serve

build: fetch
	$(DOCKER_COMPOSE) run --rm build

release: build test-aws-env
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

test-aws-env:
ifndef AWS_USER 
	$(error AWS_USER is undefined)
endif
ifndef AWS_ACCESS_KEY_ID
	$(error AWS_ACCESS_KEY_ID is undefined)
endif
ifndef AWS_SECRET_ACCESS_KEY
	$(error AWS_SECRET_ACCESS_KEY is undefined)
endif
ifndef AWS_S3_BUCKET
	$(error AWS_S3_BUCKET is undefined)
endif
ifndef HOSTNAME
	$(error HOSTNAME is undefined)
endif

redirects: test-aws-env
	docker build -t docsdockercom_redirects -f Dockerfile.redirects .
	docker run \
		--env-file aws.env \
		-e AWS_USER -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_S3_BUCKET -e HOSTNAME \
		docsdockercom_redirects

markdownlint:
	docker exec -it docsdockercom_serve_1 /usr/local/bin/markdownlint /docs/content/

htmllint:
	docker exec -it docsdockercom_serve_1 /usr/local/bin/linkcheck http://127.0.0.1:8000

all: clean build build-images serve

# Sven doesn't have docker-compose installed on some boxes, so use a compose container
compose:
	docker run --rm -it \
		-e GITHUB_USERNAME -e GITHUB_TOKEN \
		--env-file aws.env \
		-v $(CURDIR):$(CURDIR) \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /usr/bin/docker-static:/usr/bin/docker \
		-w $(CURDIR) \
		--entrypoint bash \
			svendowideit/compose


auto:
		docker run --rm -it \
			--env-file aws.env \
			-v $(CURDIR):$(CURDIR) \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v /usr/bin/docker-static:/usr/bin/docker \
			-w $(CURDIR) \
			--entrypoint make \
				svendowideit/compose \
						release

