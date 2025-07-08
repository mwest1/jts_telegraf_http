FROM golang:alpine as builder
ARG LDFLAGS=""
ARG VERSION="1.0.16"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.22/main" > /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.22/community" >> /etc/apk/repositories
RUN apk --update --no-cache add git build-base gcc

COPY . /build
WORKDIR /build

RUN go env -w GOPROXY=http://proxy.golang.org

RUN go build -ldflags "${LDFLAGS} -X main.version=${VERSION}" ./cmd/telegraf

FROM alpine:latest
LABEL version="1.0.16"

RUN apk update --no-cache && \
    adduser -S -D -H -h / telegraf
USER 0
RUN mkdir -p /etc/telegraf /var/metadata /var/cert /etc/telegraf/telegraf.d

USER telegraf
COPY --from=builder /build/telegraf /

ENTRYPOINT ["./telegraf"]
