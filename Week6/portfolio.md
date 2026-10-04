# Week 6: Portfolio and final submission

Repository: https://github.com/henryigweA/ICP-E2C97EAA-2026-REPO

## Projects
| Project | Where | Skills shown |
|---|---|---|
| 1. Shell Scripting Automation | `Week2/`, `Week3/` | Bash, cron, logging, error handling, lock files, tests |
| 2. Dockerize an Application | root `Dockerfile`, `Week4/`, `Week5/` | Multi-stage builds, non-root user, healthchecks, Compose, nginx |
| 3. CI/CD (optional) | `.github/workflows/ci.yml`, [Week5 write-up](../Week5/optional-project3-cicd.md) | GitHub Actions, automated tests, container smoke test |
| Earlier Azure work | [Azure build log](../Week5/phoenix-capstone-README.md), code in https://github.com/henryigweA/phoenix-devops-capstone | Terraform, AKS, ACR, monitoring, deploy pipeline |

## Runbooks
- [Shell automation](../Week3/runbook-shell-automation.md)
- [Docker Compose](../Week5/runbook-docker.md)

## What I learned
- Automation amplifies mistakes. That's why `cleanup.sh` has a dry-run mode and refuses to touch `/`, `/etc` or `$HOME`, and why the scripts have tests before they go anywhere near cron.
- "Success" from a tool isn't proof. Backups are listed after creation, deploys are health-checked, and in the Azure work I confirmed things a second way (`kubectl get pods`, `terraform plan`, curl from outside).
- State and reality drift apart. Half my Terraform errors (#5, #6, #7 in the error log) came from Azure doing something my code didn't know about.
- Two different "ports" are two different problems. The NSG blocked port 80 while the app happily listened on 5000 (error #8); in Compose I now keep the API port internal on purpose.
- Fast-failing beats half-working. `set -euo pipefail`, health checks and rollback all exist so a broken step stops loudly instead of quietly continuing.
