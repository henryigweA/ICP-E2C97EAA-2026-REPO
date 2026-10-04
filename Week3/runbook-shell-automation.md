# Runbook: Shell Automation Scripts

## Prerequisites
Linux/WSL with bash, tar, find, flock; Docker + curl for `deploy.sh`.

## Install
```bash
git clone <repo-url> && cd <repo>
chmod +x Week2/scripts/*.sh Week3/deploy.sh
crontab -e   # paste lines from Week3/crontab.example, fix paths
```

## Operate
| Task | Command |
|---|---|
| Manual backup | `Week2/scripts/backup.sh /src /dest 7` |
| Preview cleanup | `Week2/scripts/cleanup.sh /dir 30 --dry-run` |
| Deploy | `Week3/deploy.sh v1` |
| View logs | `tail -f ~/devops-logs/<script>.log` |

## Troubleshooting
| Symptom | Cause | Fix |
|---|---|---|
| "Another instance ... already running" | Previous run still active or crashed | `ps aux | grep <script>`; if none, `rm /tmp/<script>.lock` |
| Cron job silently does nothing | Wrong path or not executable | Use absolute paths; `chmod +x`; check `grep CRON /var/log/syslog` |
| "Refusing to clean protected path" | Guard working as intended | Point at a specific subdirectory |
| Deploy rolls back | `/health` failed | `docker compose -f Week4/docker-compose.yml logs api` |

## Rollback
`deploy.sh` auto-rolls back if the health check fails. Manual: `IMAGE_TAG=<old-tag> docker compose -f Week4/docker-compose.yml up -d`.
