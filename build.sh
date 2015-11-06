#!/bin/bash

set -e

echo "RUNNING: hugo -d /public/$DOCS_VERSION --baseUrl=http://$S3HOSTNAME/$DOCS_VERSION --config=config.toml"
hugo -d /public/$DOCS_VERSION --baseUrl=http://$S3HOSTNAME/$DOCS_VERSION --config=config.toml
