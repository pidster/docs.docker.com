.PHONY: all default build-images fetch clean clean-bucket test serve build release export shell

-include aws.env

show:
	echo "S3HOSTNAME == $(S3HOSTNAME)"

export IMAGE_TAG ?= $(shell git rev-parse --abbrev-ref HEAD)
DOCKER_IMAGE := docsdockercom:$(IMAGE_TAG)
RELEASE_LATEST ?=

ifndef RELEASE_LATEST
	export DOCS_VERSION = $(shell cat VERSION | head -n1 | awk '{print $$1}')
else
	export DOCS_VERSION =
endif

default: build-images build

build-images: fetch
#	docker build -t $(DOCKER_IMAGE) .

# The result of this step should become a hub image that the Docker projects can use for local testing
fetch:
ifndef GITHUB_USERNAME
	$(error GITHUB_USERNAME is undefined)
endif
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is undefined)
endif
	docker build \
		-t $(DOCKER_IMAGE) \
		--build-arg GITHUB_USERNAME=$(GITHUB_TOKEN) \
		--build-arg GITHUB_TOKEN=$(GITHUB_TOKEN) \
		.

serve:
	docker run --rm \
		-p 8000:8000 \
		-w /docs/ \
		$(DOCKER_IMAGE) \
		hugo server -d /public --port=8000 --watch --baseUrl=$(HUGO_BASE_URL) --bind=0.0.0.0 --config=config.toml

build:
	docker run --rm \
		-e S3HOSTNAME=$(S3HOSTNAME) \
		-w /docs/ \
		$(DOCKER_IMAGE) \
		/src/build.sh

release: build test-aws-env upload

upload:
	docker run --rm \
		-e CLEAN=$(DOCS_VERSION) \
		-e AWS_USER=$(AWS_USER) \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_S3_BUCKET=$(AWS_S3_BUCKET) \
		-e S3HOSTNAME=$(S3HOSTNAME) \
		-w /docs/ \
		$(DOCKER_IMAGE) \
		/src/build_and_upload.sh

export: build
	docker cp $$($(DATA_CONTAINER_CMD)):/public - | gzip > docs-docker-com.tar.gz

shell:
	docker run --rm -it \
		-p 8000:8000 \
		-w /docs/ \
		-e S3HOSTNAME=$(S3HOSTNAME) \
		$(DOCKER_IMAGE) \
			/bin/bash

test:
	docker rm -vf test-docs.docker.com-server ||:
	docker run -d \
		--name test-docs.docker.com-server \
		-w /docs/ \
		$(DOCKER_IMAGE) \
		hugo server -d /public --port=8000 --baseUrl=$(HUGO_BASE_URL) --bind=0.0.0.0 --config=config.toml
	sleep 2
	docker exec test-docs.docker.com-server linkcheck http://localhost:8000
	docker logs test-docs.docker.com-server
	docker rm -vf test-docs.docker.com-server

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
ifndef S3HOSTNAME
	$(error S3HOSTNAME is undefined)
endif

redirects: test-aws-env
	docker build -t docsdockercom_redirects -f Dockerfile.redirects .
	docker run \
		--rm \
		-e S3HOSTNAME=$(S3HOSTNAME) \
		-e AWS_USER=$(AWS_USER) \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(WS_SECRET_ACCESS_KEY) \
		-e AWS_S3_BUCKET=$(AWS_S3_BUCKET) \
		docsdockercom_redirects

clean:
	docker rmi -f $(DOCKER_IMAGE) 2>/dev/null ||:

clean-bucket:
	docker run --rm \
		-e S3HOSTNAME=$(S3HOSTNAME) \
		-e AWS_USER=$(AWS_USER) \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(WS_SECRET_ACCESS_KEY) \
		-e AWS_S3_BUCKET=$(AWS_S3_BUCKET) \
		-e RM_OLDER_THAN=$(RM_OLDER_THAN) \
		-w /docs/ \
		$(DOCKER_IMAGE) \
		/src/cleanup.sh

totally-clean-bucket:
	docker run --rm \
		-e S3HOSTNAME=$(S3HOSTNAME) \
		-e AWS_USER=$(AWS_USER) \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(WS_SECRET_ACCESS_KEY) \
		-e AWS_S3_BUCKET=$(AWS_S3_BUCKET) \
		--entrypoint aws docs/base s3 rm --recursive s3://$(AWS_S3_BUCKET)

markdownlint:
	docker run --rm $(DOCKER_IMAGE) /usr/local/bin/markdownlint /docs/content/

htmllint-s3:
ifndef CHECKURL
	$(error CHECKURL is undefined)
endif
	docker run $(DOCKER_IMAGE) /usr/local/bin/linkcheck $(CHECKURL)

all: clean build-images build serve

