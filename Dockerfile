
-Env
# Author: Damian Janiszewski
#
# Multistage Dockerfile definition
#
# Stage 0: golang compiler and build container
FROM golang:latest as builder-go

WORKDIR /go/src/

# Update package directory and install required utilities
#RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  #apt-utils git build-essential libtool autoconf automake pkg-config unzip \
	#cmake cmake-curses-gui uuid-dev \
  #libkrb5-dev libunwind8-dev libssl-dev libsasl2-2 libsasl2-dev libsasl2-modules \
	#swig python-dev ruby-dev libperl-dev python-epydoc \
  #g++ gcc gccgo libc6-dev make \
  #&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9.2

# Get dependencies
RUN go get -v -d -tags 'static netgo' github.com/prometheus/client_golang/prometheus/promhttp

# Copy sources
COPY *.go /go/src/
RUN CGO_ENABLED=0 GOOS=linux go build -v -a -tags 'static netgo' -ldflags '-w' env.go

# Stage 1: running container 
FROM scratch

# Copy binaries from stage 0 builder container
COPY --from=builder-go /go/src/env /usr/local/bin/

CMD ["/usr/local/bin/env"]
