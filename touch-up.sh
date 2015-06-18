#!/bin/bash -e

DOCS_DIR=$( dirname $( find /docs -name 'build.json' | head -n1 ) )
BUILD_JSON="${DOCS_DIR}/build.json"
BUILDINFO_PARTIAL="${DOCS_DIR}/layouts/partials/buildinfo.html"

# Populate an array with just docker dirs and one with content dirs
docker_dir=(`ls -d /docs/content/docker/*`)
content_dir=(`ls -d /docs/content/*`)

# Loop content not of docker/
#
# Sed to process GitHub Markdown
# 1-2 Remove comment code from metadata block
# 3 Remove .md extension from link text
# 4 Change ](/ to ](/project/ in links
# 5 Change ](word) to ](/project/word)
# 6 Change ](../../ to ](/project/
# 7 Change ](../ to ](/project/word)
# 
for i in "${content_dir[@]}"
do
   :
    if [ -d $i ] && [ "$i" != "/docs/content/docker" ] # not docker
      then
        y=${i##*/}
        find $i -type f -name "*.md" -exec sed -i.old \
        -e '/^<!.*metadata]>/g' \
        -e '/^<!.*end-metadata.*>/g' \
        -e 's/\(\]\)\([(]\)\(\/\)/\1\2\/'$y'\//g' \
        -e 's/\(\][(]\)\([A-z].*\)\(\.md\)/\1\/'$y'\/\2/g' \
        -e 's/\([(]\)\(.*\)\(\.md\)/\1\2/g'  \
        -e 's/\(\][(]\)\(\.\/\)/\1\/'$y'\//g' \
        -e 's/\(\][(]\)\(\.\.\/\.\.\/\)/\1\/'$y'\//g' \
        -e 's/\(\][(]\)\(\.\.\/\)/\1\/'$y'\//g' {} \;
      else   #do this in docker
         if [ "$i" = "/docs/content/docker" ] #do this in docker
            then
              y=${i##*/}
              find $i -type f -name "*.md" -exec sed -i.old \
                -e '/^<!.*metadata]>/g' \
                -e '/^<!.*end-metadata.*>/g' {} \;
          fi
      fi
done

#
#  Move docker directories to content
#
for i in "${docker_dir[@]}"
do
   :
    if [ -d $i ]    
      then
        mv $i /docs/content/ 
      fi
done



# Substitute in the build data in the buildinfo partial
sed "/BUILD_DATA/r $BUILD_JSON" "$BUILDINFO_PARTIAL" | sed '/BUILD_DATA/d' > "${BUILDINFO_PARTIAL}.out" \
    && mv "${BUILDINFO_PARTIAL}.out" "${BUILDINFO_PARTIAL}"
