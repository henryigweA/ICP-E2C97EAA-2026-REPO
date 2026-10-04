#!/usr/bin/env bash
# Usage: deploy.sh [image_tag=latest]
# Builds the Phoenix API image, starts it with docker compose, waits for /health,
# and rolls back to the previous image if the health check fails.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../Week2/scripts/common.sh"

TAG="${1:-latest}"
IMAGE="phoenix-api"
COMPOSE_FILE="$SCRIPT_DIR/../Week4/docker-compose.yml"
HEALTH_URL="${HEALTH_URL:-http://localhost:8080/health}"
RETRIES="${RETRIES:-15}"

require_cmd docker; require_cmd curl
acquire_lock

PREVIOUS="$(docker image inspect "$IMAGE:current" --format '{{.Id}}' 2>/dev/null || true)"

info "Building $IMAGE:$TAG"
docker build -f "$SCRIPT_DIR/../Dockerfile" -t "$IMAGE:$TAG" "$SCRIPT_DIR/.."

info "Starting stack"
IMAGE_TAG="$TAG" docker compose -f "$COMPOSE_FILE" up -d

info "Waiting for $HEALTH_URL"
for ((i=1; i<=RETRIES; i++)); do
  if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    docker tag "$IMAGE:$TAG" "$IMAGE:current"
    info "Deploy succeeded (attempt $i)"; exit 0
  fi
  sleep 2
done

error "Health check failed after $RETRIES attempts"
if [[ -n "$PREVIOUS" ]]; then
  warn "Rolling back to previous image"
  docker tag "$PREVIOUS" "$IMAGE:rollback"
  IMAGE_TAG="rollback" docker compose -f "$COMPOSE_FILE" up -d
else
  warn "No previous image to roll back to; stopping stack"
  docker compose -f "$COMPOSE_FILE" down
fi
exit 1
