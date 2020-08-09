# Builder image
FROM golang:1.14.4-alpine3.12 AS app-builder

RUN apk update && apk add --no-cache git

# Gets dependencies
WORKDIR $GOPATH/src/package/app/
COPY ./src/go.mod ./src/go.sum ./
RUN go mod download
RUN go mod verify

# Compiles the binary
COPY ./src .
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/app

# ------------------------------------------------------------------------------
# Final Image
FROM alpine:3.12.0

# Copies in requirements
COPY --from=app-builder /etc/passwd /etc/passwd
COPY --from=app-builder /etc/group /etc/group
COPY --from=app-builder /go/bin/app /bin/app
# ADD /home/vagrant/.gcloud/delineateio/platform/dev/key.json /.gcloud/key.json

# Installs dependencies
RUN apk update && apk add --no-cache libcap git wget unzip
RUN setcap 'cap_net_bind_service=+ep' /bin/app

RUN mkdir -p /hashicorp
RUN cd /hashicorp
RUN wget -q https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
RUN unzip -qq terraform_0.12.29_linux_amd64.zip
RUN install terraform /usr/local/bin/

EXPOSE 8080

# sets the command
CMD ["/bin/app"]
