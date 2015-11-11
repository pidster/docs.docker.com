#!/bin/bash

# USAGE: put a list of 404'd URLS into `brokenlinks.txt` in this dir, then run
# make buildredirects > candidates
# the `candidates` file will contain the csv lines that after eyeballing should be 
# appended to the redirects.cvs file

set -e

cd /docs/content

urls=($(grep docs.docker.com /src/brokenlinks.txt  | \
		grep -v "com/v" | \
		grep -v "\(png\|jpeg\|svg\)" | \
		sed "s/https\?:\/\/docs.docker.com\///g" | \
		sed "s/\([^/]\)$/\1\//g"| \
		sort | uniq ))

for url in "${urls[@]}"; do
	path=(${url//\// })
	#echo "look for (${path[-1]})" >&2

	# url ends in '.md' -> THIS IS A BUG THAT NEEDS FIXING IN THE REPO
	new=$(find . -type f -name "${path[-1]}")
	if [ -z "$new" ]; then
		new=$(find . -wholename "*/${path[-1]}/index.md")
		if [ -z "$new" ]; then
			new=$(find . -name "${path[-1]}.md")
		fi
	fi
	if [ -n "$new" ]; then
		# if we find more than one result need to refine search.
		arrtest=($new)
		if [ ${#arrtest[@]} -gt 1 ]; then
			echo "${#arrtest[@]} POSSIBLE $url => $new" >&2
			continue
		fi

		if [ -d "$new" ]; then
			new="$new/index.md"
		fi

		if grep draft "$new" | grep "true" > /dev/null ; then
			echo "    DRAFT ($url)" >&2
			continue
		fi
		new="${new//\/index.md/}"
		new="${new//.md/}/"
		url="${url//http:\/\/docs.docker.com\//}"
		url="${url//https:\/\/docs.docker.com\//}"
		echo "$url,${new//.\//}"
		continue
	fi
	echo " - $url" >&2
	echo "    NO (${path[-1]})" >&2
done
