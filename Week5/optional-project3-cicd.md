# Week 5: Optional Project 3, CI/CD

Two pipelines were involved.

**Deploy pipeline (original repo).** Push to `main` -> Azure login with a service principal -> build image -> push to ACR tagged with the commit SHA -> `kubectl set image` for a rolling update. It lives in https://github.com/henryigweA/phoenix-devops-capstone under `.github/workflows/deploy.yml`, with the Terraform and Kubernetes manifests. The full story is in [phoenix-capstone-README.md](phoenix-capstone-README.md).

**Test pipeline (this repo, `.github/workflows/ci.yml`).**
1. `shell-tests`: runs `Week3/tests/test_scripts.sh` (Project 1).
2. `docker-smoke-test`: builds the image, starts the Compose stack, waits until nginx answers on `/health`, checks the API container isn't running as root, then tears the stack down (Project 2).

It also runs automatically after the unzip workflow (`unzip-and-structure.yml`) finishes.

Not done: the Azure deploy isn't gated on these tests. Making the deploy depend on CI is the obvious next step.
