# Week 5 - Reliability Testing (Project 2)

Run each test, then record the real result in the "Observed" column.

| # | Test | Command | Expected | Observed |
|---|---|---|---|---|
| 1 | Health endpoint | `curl localhost:8080/health` | HTTP 200 | |
| 2 | Container crash recovery | `docker kill <api-container>` | Restarted by `restart: unless-stopped`, healthy again | |
| 3 | Start order | `docker compose down && up -d` | proxy waits for api healthy | |
| 4 | Not root | `docker compose exec api id` | uid=1001 (appuser) | |
| 5 | API not exposed directly | `curl localhost:5000/health` | Connection refused | |
| 6 | Bad deploy rollback | Break `/health`, run `Week3/deploy.sh bad` | Auto rollback, exit 1 | |
| 7 | Clean rebuild | `docker compose build --no-cache` | Succeeds | |
