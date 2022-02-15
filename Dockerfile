# syntax=docker/dockerfile:1.3
ARG DOCKER_VERSION=latest
ARG BUILDX_VERSION=v0.7

FROM docker/buildx-bin:${BUILDX_VERSION} as buildx-bin

FROM docker:${DOCKER_VERSION}
ARG COMPOSE_VERSION=2.2.3
ARG COMPOSE_SWITCH_VERSION=1.0.4
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

RUN apk add --no-cache \
    curl \
    make \
    bash
COPY --from=buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx
RUN arch=${TARGETPLATFORM}; \
    arch=`echo $arch | sed -E 's/^linux\/amd64$/linux-x86_64/g'`; \
    arch=`echo $arch | sed -E 's/^linux\/arm64$/linux-aarch64/g'`; \
    arch=`echo $arch | sed -E 's/^linux\/s390x$/linux-s390x/g'`; \
    arch=`echo $arch | sed -E 's/^linux\/arm\/v7$/linux-armv7/g'`; \
    arch=`echo $arch | sed -E 's/^linux\/arm\/v6$/linux-armv6/g'`; \
    if [[ $arch == "${TARGETPLATFORM}" ]]; then echo "Unable to convert \"$arch\""; exit 1; fi; \
    curl -fL https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-${arch} -o /usr/libexec/docker/cli-plugins/docker-compose \
    && chmod +x /usr/libexec/docker/cli-plugins/docker-compose
RUN arch=${TARGETPLATFORM}; \
    arch=`echo $arch | sed -E 's/^linux\/amd64$/linux-amd64/g'`; \
    arch=`echo $arch | sed -E 's/^linux\/arm64$/linux-arm64/g'`; \
    if [[ $arch == "${TARGETPLATFORM}" ]]; then echo "Unable to convert \"$arch\""; exit 1; fi; \
    curl -fL https://github.com/docker/compose-switch/releases/download/v${COMPOSE_SWITCH_VERSION}/docker-compose-${arch} -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose
