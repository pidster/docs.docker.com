#!/bin/bash

set -e

if [[ "$AWS_S3_BUCKET" =~ "/" ]] ; then
    BUCKET_PATH=$( echo "$AWS_S3_BUCKET" | sed "s/[^\/]*\///" )
    BUCKET_PATH+="/"
    AWS_S3_BUCKET=$( echo "$AWS_S3_BUCKET" | sed "s/\/.*//")
else
    BUCKET_PATH=
fi

[ -z "$RM_OLDER_THAN" ] && exit 1
CUTOFF_UNIX_TS=$( date --date "$RM_OLDER_THAN" '+%s' )
aws s3 ls --recursive s3://$AWS_S3_BUCKET/$BUCKET_PATH | while read -a LINE ; do
    DATE="${LINE[0]}"
    TIME="${LINE[1]}"
    SIZE="${LINE[2]}"
    NAME="${LINE[*]:3}"

    VERSION_REGEX="^${BUCKET_PATH}v[0-9]+\.[0-9]+/"
    UNIX_TS=$( date --date "$DATE $TIME" "+%s" )

    if [[ "$NAME" =~ $VERSION_REGEX ]] || [[ "$CUTOFF_UNIX_TS" -le "$UNIX_TS" ]] ; then
        echo "Keeping $NAME"
        continue
    fi

    echo "Creating redirect for $NAME"
    aws s3 cp "s3://$AWS_S3_BUCKET/$NAME" "s3://$AWS_S3_BUCKET/$NAME" --website-redirect="/${BUCKET_PATH}index.html" --acl=public-read > /dev/null
done

