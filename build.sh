#!/bin/bash

set -e

# TODO: need to add the $DOCS_VERSION to the baseURL without duplicating the /
hugo -d /public/$DOCS_VERSION --config=config.toml --baseURL="$S3HOSTNAME"
