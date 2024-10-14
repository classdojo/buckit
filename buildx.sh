#!/bin/sh

# Architectures to build for
PLATFORMS=${PLATFORMS:=linux/amd64,linux/arm64}

# Docker layer target
TARGET=${1:-runner}

# Tag
IMAGE_TAG=$(git rev-parse --short HEAD)
[ ! -z "$2" ] && IMAGE_TAG="$2"

# ECR repository
IMAGE_REPO="347708466071.dkr.ecr.us-east-1.amazonaws.com/classdojo/buckit"

if ! docker buildx inspect us-east-1-ci-buildkit >/dev/null 2>&1; then
  echo "Creating buildx builders..."
  docker buildx create --bootstrap \
    --name=us-east-1-ci-buildkit \
    --driver=remote tcp://us-east-1-ci-buildx-amd64-a64473a383bb6272.elb.us-east-1.amazonaws.com:9999
  docker buildx create \
    --name=us-east-1-ci-buildkit --bootstrap --append \
    --driver=remote tcp://us-east-1-ci-buildx-arm64-b72c4d4534151016.elb.us-east-1.amazonaws.com:9999
fi

DOCKER_BUILDKIT=1 time docker buildx build \
  --builder us-east-1-ci-buildkit \
  --pull \
  --push \
  --target="${TARGET}" \
  --platform="${PLATFORMS}" \
  -t "${IMAGE_REPO}:${IMAGE_TAG}" .