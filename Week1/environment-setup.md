# Environment Setup

| Tool | Purpose | Verify |
|---|---|---|
| Git / Git Bash | Version control | `git --version` |
| Linux shell (Git Bash / WSL) | Run bash scripts | `bash --version` |
| Docker Desktop | Containers | `docker --version && docker compose version` |
| Python 3.13 + pip | Run the app | `python --version` |
| Terraform, Azure CLI, kubectl | Bonus infra work | `terraform -v`, `az version`, `kubectl version --client` |

Note for Windows: `flock` and `find -mtime` need WSL or a full Linux environment. Git Bash lacks `flock`; run the Week2/3 scripts in WSL or any Linux machine/VM.

Issues hit during setup are recorded in the main error log: `Week5/phoenix-capstone-README.md`, section 5.
