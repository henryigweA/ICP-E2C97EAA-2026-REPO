# Week 5: Reliability testing (Project 2)

| # | Test | How | Status |
|---|---|---|---|
| 1 | Health endpoint answers through nginx | `curl localhost:8080/health` | Verified automatically on every CI run (`docker-smoke-test`, green) |
| 2 | API container is not root | `docker compose exec api id -u` | Verified automatically on every CI run |
| 3 | Stack starts clean from scratch | `docker compose up -d --build` | Verified automatically on every CI run |
| 4 | Crash recovery | `docker kill <api-container>`; expect `unless-stopped` to restart it | Manual test, not yet run |
| 5 | API port not exposed on host | `curl localhost:5000/health` should be refused | Manual test, not yet run |
| 6 | Bad deploy rolls back | break `/health`, run `Week3/deploy.sh bad`; expect rollback and exit 1 | Manual test, not yet run |

Rows 1-3 are proven by the CI workflow itself, not by me running them by hand. Rows 4-6 are the next things to try; they depend on a local Docker setup.
