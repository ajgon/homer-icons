FROM alpine:3.14

RUN apk add imagemagick

COPY entrypoint.sh /usr/bin/entrypoint.sh

WORKDIR /icons

ENTRYPOINT ["entrypoint.sh"]
