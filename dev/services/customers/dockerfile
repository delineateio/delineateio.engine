FROM golang:1.14.4-alpine3.12 AS builder

RUN apk update && apk add --no-cache git
ENV USER=appuser
ENV UID=10001

# https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR $GOPATH/src/package/app/

# Gets dependencies
COPY ./src/go.mod ./src/go.sum ./
RUN go mod download
RUN go mod verify

# Compiles the binary
COPY ./src .
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/app

# Final Image
FROM alpine:3.12.0

ARG MAINTAINER
ARG ENV
ARG LOCATION
ARG BUILD_DATE
ARG VCS_REF

# http://label-schema.org/rc1/
LABEL maintainer=$MAINTAINER
LABEL io.delineate.maintainer=$MAINTAINER
LABEL io.delineate.env=$ENV
LABEL io.delineate.location=$LOCATION
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="delineate.io core"
LABEL org.label-schema.description="Core microservice that is used within delineate.io"
LABEL org.label-schema.url="https://www.delineate.io/"
LABEL org.label-schema.vcs-url="https://github.com/delineateio/delineateio.engine"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="delineate.io"

# Copies in requirements
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /go/bin/app /bin/app

COPY ./config /config
EXPOSE 8080

# Use an unprivileged user.
USER appuser:appuser

# sets the command
CMD ["/bin/app"]
