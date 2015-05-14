#
# See the top level Makefile in https://github.com/docker/docker for usage.
#
FROM debian:jessie
MAINTAINER Sven Dowideit <SvenDowideit@docker.com> (@SvenDowideit)

RUN apt-get update \
	&& apt-get install -y \
		gettext \
		git \
		libssl-dev \
		make \
		python-dev \
		python-pip \
		python-setuptools \
		vim-tiny 


# Required to publish the documentation.
# The 1.4.4 version works: the current versions fail in different ways
# TODO: Test to see if the above holds true
RUN pip install awscli==1.4.4 pyopenssl==0.12

ENV HUGO_VERSION 0.13
RUN curl -sSL https://github.com/spf13/hugo/releases/download/v0.13/hugo_${HUGO_VERSION}_linux_amd64.tar.gz | tar -v -C /usr/local/bin -xz --strip-components 1 && \
	mv /usr/local/bin/hugo_${HUGO_VERSION}_linux_amd64 /usr/local/bin/hugo

WORKDIR /docs
EXPOSE 8000
# CMD ["mkdocs", "serve"]


COPY . /docs

# TODO: Find out what this was for
# COPY README.md /docs/sources/index.md


# RUN ./build.sh

