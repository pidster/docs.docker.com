FROM docs-base:hugo-github-linking
MAINTAINER Mary Anthony <mary@docker.com> (@moxiegirl)

WORKDIR /src

COPY requirements.txt /src/
RUN pip install -r requirements.txt

COPY . /src/
ARG GITHUB_USERNAME
ARG GITHUB_TOKEN

RUN ./fetch_content.py /docs all-projects.yml

