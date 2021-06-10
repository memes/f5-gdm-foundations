# TODO: @memes - configure as needed
FROM golang:1.15.0 AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -o APP

# TODO: @memes - set base alpine
FROM alpine:3.12.1
# Default to 'master' so that a build outside of CI process has valid links
ARG COMMIT_SHA="master"
ARG TAG_NAME="unreleased"
# TODO: @memes - set labels correctly
LABEL maintainer="Matthew Emes <memes@matthewemes.com>" \
      org.opencontainers.image.title="APP" \
      org.opencontainers.image.authors="memes@matthewemes.com" \
      org.opencontainers.image.description="Foo bar" \
      org.opencontainers.image.url="https://github.com/memes/APP" \
      org.opencontainers.image.source="https://github.com/memes/APP/tree/${COMMIT_SHA}" \
      org.opencontainers.image.documentation="https://github.com/memes/APP/tree/${COMMIT_SHA}/README.md" \
      org.opencontainers.image.version="${TAG_NAME}" \
      org.opencontainers.image.revision="${COMMIT_SHA}" \
      org.opencontainers.image.licenses="MIT" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="APP" \
      org.label-schema.description="Foo bar" \
      org.label-schema.url="https://github.com/memes/APP" \
      org.label-schema.vcs-url="https://github.com/memes/APP/tree/${COMMIT_SHA}" \
      org.label-schema.usage="https://github.com/memes/APP/tree/${COMMIT_SHA}/README.md" \
      org.label-schema.version="${TAG_NAME}" \
      org.label-schema.vcs-ref="${COMMIT_SHA}" \
      org.label-schema.license="MIT"

# TODO: @memes - review if updated package required
RUN apk --no-cache add ca-certificates=20191127-r4
WORKDIR /run
COPY --from=builder /src/APP /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/APP"]
