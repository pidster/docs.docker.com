#!/bin/bash
set -e

URL=http://$HUGO_BASE_URL:8000
hugo server -d /public --port=8000 --baseUrl=$HUGO_BASE_URL --bind=$HUGO_BIND_IP &
until curl --fail --silent $URL ; do \
  sleep 1 ; \
done
exec python /src/docvalidate.py $URL
