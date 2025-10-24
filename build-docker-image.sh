
#!/usr/bin/env bash
set -euo pipefail

# Get latest release tag from GitHub API
LATEST_TAG=$(curl -s https://api.github.com/repos/minio/minio/releases/latest | grep '"tag_name"' | cut -d '"' -f4)
echo "Latest release tag: $LATEST_TAG"

TMP_DIR=$(mktemp -d)
echo "Cloning into temp dir: $TMP_DIR"
git clone --depth 1 --branch "$LATEST_TAG" https://github.com/minio/minio.git "$TMP_DIR/minio"

cd "$TMP_DIR/minio"

make build  

docker build -t "minio/minio:$LATEST_TAG" .
echo "Docker image built: minio/minio:$LATEST_TAG"
