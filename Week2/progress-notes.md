# Week 2 - Project 1: Shell Scripting Automation (development)

## Done this week
- `scripts/common.sh`: shared logging (`info/warn/error`), `set -euo pipefail`, `trap ERR` handler, lock file via `flock`.
- `scripts/backup.sh`: timestamped tar.gz, archive verification, retention policy.
- `scripts/cleanup.sh`: age-based deletion with `--dry-run` and protected-path guard.

## Design decisions
- **Fail fast:** `set -euo pipefail` so a failing step never silently continues.
- **Verify, don't assume:** the backup is listed with `tar -tzf` after creation.
- **Safety:** cleanup refuses `/`, `/etc`, `$HOME`, etc. because "automation amplifies mistakes".
- **No overlap:** `flock` stops a slow cron run from colliding with the next.

## Try it
```bash
bash Week2/scripts/backup.sh ./some-dir /tmp/backups 7
bash Week2/scripts/cleanup.sh /tmp/backups 30 --dry-run
```
