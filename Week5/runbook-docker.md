# Runbook: Phoenix API (Docker Compose)

## Start / stop
```bash
docker compose -f Week4/docker-compose.yml up -d --build
docker compose -f Week4/docker-compose.yml down
```

## Verify
`curl http://localhost:8080/health` returns 200; `docker compose ps` shows `healthy`.

## Troubleshooting
| Symptom | Check | Fix |
|---|---|---|
| `api` unhealthy | `docker compose logs api` | Fix app error, rebuild |
| 502 from nginx | Is `api` healthy? | Restart api: `docker compose restart api` |
| Port 8080 in use | `lsof -i :8080` | Change the host port in compose |
| Stale image | `docker images` | `up -d --build --force-recreate` |
