#!/bin/bash
set -e

if ! aws s3 ls s3://$AWS_S3_BUCKET ; then
	aws s3 mb s3://$AWS_S3_BUCKET
fi
/src/update-redirects.sh

if [ -n "$CLEAN" ] ; then
  aws s3 rm --recursive s3://$AWS_S3_BUCKET/$CLEAN
fi
aws s3 sync --acl=public-read /public/ s3://$AWS_S3_BUCKET
