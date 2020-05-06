FROM alpine:latest

RUN apk add --no-cache git grep

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
