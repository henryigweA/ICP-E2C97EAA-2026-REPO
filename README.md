<!-- icp-structured -->
# Phoenix DevOps: InternCareerPath internship submission

Intern ID `ICP-E2C97EAA-2026` / Repo ID `REPO-86FFB2D7`

This started as a challenge I set myself: take a tiny Flask inventory API and get it onto Azure the way a team would, with Terraform, containers, a pipeline, and an alert that really emails me when pods keep restarting. That ran on a free-tier subscription in South Africa North and went wrong ten different ways before it worked. The whole list is in [Week5/phoenix-capstone-README.md](Week5/phoenix-capstone-README.md). My favourites are downloading the macOS Terraform build by mistake, and Git Bash quietly rewriting `/subscriptions/...` into `C:/Program Files/Git/subscriptions/...`.

For the internship I picked two projects from the bank and built them around that same app.

## Project 1: Shell Scripting Automation (Weeks 2-3)

Three scripts, one shared helper file.

- `Week2/scripts/backup.sh` makes a timestamped tarball, then lists its contents to prove it's readable (an exit code of 0 from `tar` isn't proof), and deletes backups past a retention age.
- `Week2/scripts/cleanup.sh` deletes old files, supports `--dry-run`, and refuses to run on `/`, `/etc`, `$HOME` and similar. I added that guard because a typo in a cron job is exactly how you delete the wrong thing at 3am.
- `Week3/deploy.sh` builds the image, starts the Compose stack, polls `/health`, and rolls back to the previous image if the check never passes.
- `common.sh` holds logging to `~/devops-logs/`, an ERR trap that reports the failing line, and a `flock` lock so overlapping cron runs can't collide.

`bash Week3/tests/test_scripts.sh` runs nine checks (missing source, no arguments, retention, dry-run, protected paths, and so on). It needs Linux or WSL. Git Bash has no `flock`.

## Project 2: Dockerize an Application (Weeks 4-5)

My first Dockerfile worked but was single-stage, ran as root and had no health check. The version at the repo root now:

- builds dependencies in a throwaway stage and copies only the virtualenv across
- runs as a non-root user
- has a `HEALTHCHECK` against `/health`
- ships with a `.dockerignore` so `.git`, `terraform/` and `.env` don't end up in the image

`Week4/docker-compose.yml` runs the API behind nginx. The API port is not published to the host. nginx waits for the API's health check to pass before it starts, and it reaches the API by service name. `Week5/reliability-testing.md` has the failure-test table: three checks run automatically in CI, three are manual.

## Extra: the Azure side and CI

The Terraform, AKS manifests and the deploy pipeline are in my earlier repo, [phoenix-devops-capstone](https://github.com/henryigweA/phoenix-devops-capstone). The build log and error list from that work are in this repo: [Week5/phoenix-capstone-README.md](Week5/phoenix-capstone-README.md). In this repo, `.github/workflows/ci.yml` runs the Project 1 tests and a Compose smoke test (health through nginx, container not root) on every push. More in [Week5/optional-project3-cicd.md](Week5/optional-project3-cicd.md).

## Layout

```
Week1/   project selection, environment setup, Linux and Git notes
Week2/   Project 1 scripts + progress notes
Week3/   deploy.sh, cron examples, tests, runbook
Week4/   Compose file, nginx config, technical notes
Week5/   reliability test status, Docker runbook, CI/CD write-up, Azure build log
Week6/   portfolio, final checklist, LinkedIn draft
app.py, requirements.txt, Dockerfile    the application
.github/workflows/                       CI tests + the unzip/structure workflow
```

## Run it

```bash
bash Week3/tests/test_scripts.sh
docker compose -f Week4/docker-compose.yml up -d --build
curl http://localhost:8080/health
```

Runbooks: [shell scripts](Week3/runbook-shell-automation.md), [Docker Compose](Week5/runbook-docker.md).

## What's still missing

The API stores everything in memory, so data disappears on restart. The AKS cluster in the earlier repo runs one node and one pod to stay inside the free tier, so there's no autoscaling, and its deploy isn't gated on these tests yet. Three of the reliability tests (crash recovery, closed API port, rollback) are written up but not run by hand; the other three run automatically in CI. And `backup.sh`/`cleanup.sh` have only been run against test directories, not a production server.
