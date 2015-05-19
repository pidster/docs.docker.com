#
# See the top level Makefile in https://github.com/docker/docker for usage.
#
FROM docs-base:hugo-feature-work
MAINTAINER Mary Anthony <mary@docker.com> (@moxiegirl)

# This section ensures we pull the correct version of each
# sub project
ENV COMPOSE_BRANCH hugo-work
ENV SWARM_BRANCH v0.2.0
ENV MACHINE_BRANCH docs
ENV DISTRIB_BRANCH docs
ENV ENGINE_BRANCH uniform-structure

#######################
# Get Source
#######################
WORKDIR /docs/source
RUN git clone -b ${ENGINE_BRANCH} https://github.com/moxiegirl/docker.git
RUN git clone -b ${COMPOSE_BRANCH} https://github.com/moxiegirl/compose.git

WORKDIR /docs/source/docker
RUN git fetch
RUN git rebase origin/${ENGINE_BRANCH}

WORKDIR /docs/source/compose
RUN git fetch
RUN git rebase origin/${COMPOSE_BRANCH}

WORKDIR /docs
COPY . /docs
RUN mkdir content/docker
RUN cp -R source/docker/docs/sources/* content/docker

RUN mkdir content/compose
RUN cp -R source/compose/docs/* content/compose

#WORKDIR /docs/content
RUN find . -type f -name "Dockerfile" -delete

WORKDIR /docs
EXPOSE 8000






