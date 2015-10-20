#!/bin/sh

# create the s3_website.json file from redirect.csv
cat <<HERE > s3_website.json
{
  "ErrorDocument": {
    "Key": "404.html"
  },
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "RoutingRules": [
HERE

#    { "Condition": { "KeyPrefixEquals": "jsearch/index.html" }, "Redirect": { "HostName": "$HOSTNAME", "ReplaceKeyPrefixWith": "jsearch/" } },
grep --invert-match "^#" /src/redirects.csv | sed 's/\(.*\),\(.*\)/    { "Condition": { "KeyPrefixEquals": "\1" }, "Redirect": { "HostName": "$HOSTNAME", "ReplaceKeyPrefixWith": "\2" } },/' >> s3_website.json
# and one last one because amazone won't put up with trailing commas
echo '    { "Condition": { "KeyPrefixEquals": "svendowideit" }, "Redirect": { "HostName": "$HOSTNAME", "ReplaceKeyPrefixWith": "examples/apt-cacher-ng/" } }' >> s3_website.json

cat <<HERE >> s3_website.json
  ]
}
HERE

s3conf=$(cat s3_website.json | envsubst)
echo
echo "Setting up $AWS_S3_BUCKET as an s3 website with the following config"
echo
echo $s3conf
echo


echo "RUN: aws s3api put-bucket-website --bucket $AWS_S3_BUCKET --website-configuration [json]"
aws s3api put-bucket-website --bucket $AWS_S3_BUCKET --website-configuration "$s3conf"

echo
echo "exit code: $?"
echo
