FROM debian:jessie
MAINTAINER Mary Anthony <mary@docker.com>

RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	s3cmd \
	--no-install-recommends

ENV HUGO_VERSION 0.13
RUN curl -sSL https://github.com/spf13/hugo/releases/download/v0.13/hugo_${HUGO_VERSION}_linux_amd64.tar.gz | tar -v -C /usr/local/bin -xz --strip-components 1 && \
	mv /usr/local/bin/hugo_${HUGO_VERSION}_linux_amd64 /usr/local/bin/hugo


WORKDIR /usr/src/docs/

# add files
VOLUME /usr/src/docs/
EXPOSE 1313

# ENTRYPOINT [ "hugo" ]
# CMD hugo server -w --baseUrl=http://dockerhost --appendPort=false
