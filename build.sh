#!/bin/bash

set -e

echo "RUNNING: hugo -d /public/$DOCS_VERSION --baseUrl=$S3HOSTNAME --config=config.toml"
hugo -d /public/$DOCS_VERSION --baseUrl="http://$S3HOSTNAME" --config=config.toml
