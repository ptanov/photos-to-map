FROM debian:10-slim

RUN apt-get update \
	&& apt-get install -y exiftool \
	&& apt-get clean

VOLUME /data

COPY suffix.xml /photos-to-map/
COPY prefix.xml /photos-to-map/
COPY photos-to-map.sh /photos-to-map/

ENTRYPOINT ["/photos-to-map/photos-to-map.sh"]
CMD ["/data"]
