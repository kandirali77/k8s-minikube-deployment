FROM ruby:3.0-alpine3.12

WORKDIR /usr/src/app

RUN apk update && apk add curl

RUN addgroup -S appgroup && \
    adduser -S -s /sbin/nologin -G appgroup appuser && \
    chown appuser:appgroup .

USER appuser
#
# Better to copy single file since source is not complex
#
COPY --chown=appuser:appgroup ./http_server/http_server.rb .

CMD ["ruby", "./http_server.rb"]
