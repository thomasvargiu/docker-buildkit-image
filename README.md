# thomasvargiu/docker-buildkit

Includes:
- [`docker`](https://github.com/moby/moby)
- [`buildx`](https://github.com/docker/buildx/)
- [`docker-compose`](https://github.com/docker/compose) v2
- [`compose-switch`](https://github.com/docker/compose-switch)

Included packages:
- `curl`
- `make`
- `bash`

## Usage

### Multi-arch in gitlab-ci

This image can be used to build multi-arch images with [`buildx`](https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images).

In `.gitlab-ci.yml`:

```yaml
variables:
  DOCKER_HOST: tcp://docker:2375
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""
  DOCKER_REGISTRY: cr.example.it
  DOCKER_REPOSITORY: my-repo

# use this image
image: thomasvargiu/docker-buildkit
# start a docker-dind service for isolation
services:
  - docker:20.10.12-dind

stages:
  - build

Build:
  stage: build
  script:
    # install arm64 QEMU emulator
    - docker run --privileged --rm tonistiigi/binfmt --install arm64
    # create buildx builder
    - docker buildx create --use
    # build and publish
    - |
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}:${RELEASE_TAG}" \
        --push \
        .
```
