#!/bin/bash -e

# Uncomment hugo metadata
find /docs -type f -name '*.md' -exec sed -i.old  -e '/^<!.*metadata]>/g' -e '/^<!.*end-metadata.*>/g' {} \;
