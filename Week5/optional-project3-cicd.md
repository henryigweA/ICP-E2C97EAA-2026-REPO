# Week 5: Optional Project 3, CI/CD

Two pipelines, each with a separate job.

**Deploy pipeline** (`.github/workflows/deploy.yml`, written earlier for the Azure work)
push to `main` -> Azure login with a service principal -> build image -> push to ACR tagged with the commit SHA -> `kubectl set image` for a rolling update.
GitHub only runs workflows from the repo root, which is why this one is not inside a Week folder.

**Test pipeline** (`.github/workflows/ci.yml`, added for the internship projects)
1. `shell-tests`: runs `Week3/tests/test_scripts.sh` (Project 1).
2. `docker-smoke-test`: builds the image, brings up the Compose stack, waits for nginx to answer on `/health`, tears it down (Project 2).

What it does not do yet: it doesn't gate the Azure deploy. `deploy.yml` still runs on every push to `main` regardless of whether the tests pass. Making deploy depend on CI is the obvious next step.

The Terraform, AKS manifests and the full build/error log are in `terraform/`, `k8s/` and [phoenix-capstone-README.md](phoenix-capstone-README.md).
