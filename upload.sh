#!/bin/bash
set -e

if [ -n "$CLEAN" ] ; then
  aws s3 rm --recursive s3://$AWS_S3_BUCKET/$CLEAN
fi
aws s3 sync --acl=public-read . s3://$AWS_S3_BUCKET
