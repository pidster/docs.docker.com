.PHONY: all build default release

default: release

all: build

build: 
	docker build --rm --force-rm -t docker:docs .

release: build
	docker run --rm -it docker:docs
