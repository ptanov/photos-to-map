#!/bin/bash

set -e

INPUT=data.cvs
IFS=$'\t'

cat "$(dirname "${0}")/prefix.xml"
while read -r Directory FileName GPSLatitude GPSLongitude GPSAltitude GPSDateTime; do
	if [ "-" == "${GPSLatitude}" -o "-" == "${GPSLongitude}" -o "-" == "${GPSDateTime}" ]; then
		continue
	fi

	before=$(date -d @"$(( $(date -d "${GPSDateTime:0:10}Z" '+%s') - 86400 ))" --utc +%F)
	after=$(date -d @"$(( $(date -d "${GPSDateTime:0:10}Z" '+%s') + 86400 ))" --utc +%F)
	filter="${before}%20-%20${after}"

	coordinates="${GPSLongitude},${GPSLatitude}"
	if ! [ -z "${GPSAltitude}" ]; then
		coordinates="${coordinates},${GPSAltitude}"
	fi

	echo "    <Placemark>"
	echo "        <name>[${GPSDateTime:0:10}] ${FileName}</name>"
	echo "        <description><![CDATA[<p><a href=\"https://photos.google.com/search/${filter}\">Days</a>, <a href=\"https://photos.google.com/search/${GPSDateTime:0:10}\">Day</a>, <a href=\"https://photos.google.com/search/${GPSDateTime:0:10}%20${FileName}\">Exact</a></p><p>${Directory}/<b>${FileName}</b></p><p><b>Date:</b> ${GPSDateTime}</p>]]></description>"
	echo "        <styleUrl>#mainStyleMap</styleUrl>"
	echo "        <Point><coordinates>${coordinates}</coordinates></Point>"
	echo "    </Placemark>"
done <<< "$(exiftool -c "%+.6f" -Directory -FileName -GPSLatitude# -GPSLongitude# -GPSAltitude# -GPSDateTime -dateFormat "%Y-%m-%dT%H:%M:%S%z" -T -args -ex -r "${1:-.}")"

cat "$(dirname "${0}")/suffix.xml"
