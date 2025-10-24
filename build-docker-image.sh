#!/usr/bin/env bash
set -euo pipefail

LATEST_TAG=$(curl -s https://api.github.com/repos/minio/minio/releases/latest | grep '"tag_name"' | cut -d '"' -f4 | tr '[:lower:]' '[:upper:]')
echo "Latest release tag: $LATEST_TAG"
echo "tag=$LATEST_TAG" >> $GITHUB_OUTPUT
RELEASE_BODY=$(curl -s https://api.github.com/repos/minio/minio/releases/latest | grep '"body":' | cut -d ':' -f2- | sed 's/^ "//;s/",$//')
echo "Description of the release: $RELEASE_BODY"
echo "body=$RELEASE_BODY" >> $GITHUB_OUTPUT

TMP_DIR=$(mktemp -d)
echo "Cloning into temp dir: $TMP_DIR"
git clone --depth 1 --branch "$LATEST_TAG" https://github.com/minio/minio.git "$TMP_DIR/minio"

cd "$TMP_DIR/minio"

make build

echo "bp=$(pwd)" >> $GITHUB_OUTPUT

docker build -t "ghcr.io/jadolg/minio:$LATEST_TAG" .
echo "Docker image built: ghcr.io/jadolg/minio:$LATEST_TAG"
docker push "ghcr.io/jadolg/minio:$LATEST_TAG"
