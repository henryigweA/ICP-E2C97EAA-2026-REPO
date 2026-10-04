# Week 4 - Project 2: Dockerize an Application

## What changed from the first Dockerfile
| Before | After | Why |
|---|---|---|
| Single stage | Multi-stage (builder + runtime) | Build tooling and pip cache stay out of the final image |
| Runs as root | Non-root `appuser` (uid 1001) | Limits damage if the container is compromised |
| No health check | `HEALTHCHECK` on `/health` | Docker/Compose can detect a broken app |
| No `.dockerignore` | Added | Smaller context, no `.git`/terraform/secrets in the image |
| Single container | Compose: `api` + `nginx` proxy | Practises service networking and dependencies |

## Compose concepts used
- **Service networking:** nginx reaches the app by service name `api:5000` on the `backend` network; the API port is not published to the host.
- **Environment config:** `APP_ENV`, `IMAGE_TAG` via env vars with defaults.
- **Health checks + `depends_on: service_healthy`:** nginx starts only when the API is healthy.
- **Restart policy:** `unless-stopped`.

## Commands
```bash
docker compose -f Week4/docker-compose.yml up -d --build
curl http://localhost:8080/health
docker compose -f Week4/docker-compose.yml ps     # api should show (healthy)
docker images phoenix-api                         # record the size
docker compose -f Week4/docker-compose.yml down
```

## Image optimization record
Record your real numbers after building (compare against the old single-stage image):

| Image | Size |
|---|---|
| Old single-stage (`python:3.13-slim`) | _fill in from `docker images`_ |
| New multi-stage | _fill in from `docker images`_ |
