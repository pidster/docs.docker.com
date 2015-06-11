#!/bin/bash -e

DOCS_DIR=$( dirname $( find /docs -name 'build.json' | head -n1 ) )
BUILD_JSON="${DOCS_DIR}/build.json"
BUILDINFO_PARTIAL="${DOCS_DIR}/layouts/partials/buildinfo.html"

# Uncomment hugo metadata
find /docs -type f -name '*.md' -exec sed -i.old  -e '/^<!.*metadata]>/g' -e '/^<!.*end-metadata.*>/g' {} \;

# Substitute in the build data in the buildinfo partial
sed "/BUILD_DATA/r $BUILD_JSON" "$BUILDINFO_PARTIAL" | sed '/BUILD_DATA/d' > "${BUILDINFO_PARTIAL}.out" \
    && mv "${BUILDINFO_PARTIAL}.out" "${BUILDINFO_PARTIAL}"
