#!/bin/bash

set -e

SRC_FOLDER="${1}"
TARGET_FOLDER="${2}"

count=0

shopt -s globstar

cd "${SRC_FOLDER}"

count=0
for src in **/*.jpg **/*.JPG ; do
	target="${TARGET_FOLDER}${src}"
	if [ -f "${src}" ] && [ "${src}" -nt "${target}" ]; then
		((++count))
	fi
done

echo "Count: ${count}"
count=0

start=$(date +%s%N)
before=${start}

for src in **/*.jpg **/*.JPG ; do
# or using find /tmp \( -name '*.pdf' -or -name '*.doc' \) -print0 | xargs -0 rm
	target="${TARGET_FOLDER}${src}"
	parentDir="${target%/*}"
#	slower: parentDir="$(dirname -- "${target}")"

	if ! [ -d "${parentDir}" ]; then
		mkdir -p "$(dirname "${target}")"
	fi
	if [ -f "${src}" ] && [ "${src}" -nt "${target}" ]; then
		convert "${src}" -filter point -resize 200 "${target}"
		# -scale 100
		# -sample 100
		# -thumbnail looses exif data
		((++count))
		if [[ $(( count % 1000 )) == 0 ]]; then
			after=$(date +%s%N)
			diff=$(((after-before)/1000000000))
			before=${after}
			echo "1000 for ${diff} sec"
		fi
	fi
done

after=$(date +%s%N)
diff=$(((after-start)/1000000000/60))

echo "Finished ${diff} mins"

cp --backup=t **/*.gpx "${TARGET_FOLDER}"
find . -maxdepth 1 -type f -name "*.gpx.*" -not -name "*.gpx" -exec mv "{}" "{}".gpx \;

