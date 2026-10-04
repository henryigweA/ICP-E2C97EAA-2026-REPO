# Phoenix Inventory API: Azure build log (original capstone)

This is the build log from the Azure project that came before the internship work. The Terraform, Kubernetes manifests and deploy workflow live in the original repo: https://github.com/henryigweA/phoenix-devops-capstone. The write-up is kept here so the whole story is in one place.

**The app:** a tiny in-memory Flask inventory API: `GET /health`, `GET /products`, `POST /products`, `GET /products/<id>`. No database, no frontend, so the DevOps work is the point.

**The mission:** take it from "runs on one laptop" to "runs in Azure, redeploys itself on every push, and tells someone if it's unhealthy", without touching the app's logic.

## Architecture

```
Resource Group: rg-phoenix-dev  (South Africa North)
|
+-- VNet (10.0.0.0/16)
|    +-- Subnet snet-web (10.0.1.0/24)
|         +-- NSG nsg-web  (100: allow 5000, 110: allow 80)
|         +-- AKS node(s) live here
|
+-- ACR: acrphoenixdev001        stores the Docker image
+-- AKS: aks-phoenix-dev         runs the container
|    +-- Deployment: phoenix-api -> keeps 1 pod alive
|         +-- Service: phoenix-api-service (LoadBalancer), :80 -> pod :5000
|
+-- Log Analytics: log-phoenix-dev   (Container Insights via oms_agent)
+-- Monitor Alert: phoenix-api-restart-alert
     any pod restarted > 2 times in 5 min -> email via Action Group ag-phoenix-alerts
```

Request flow: browser/curl -> public IP :80 -> NSG -> Load Balancer/Service -> pod :5000 -> Flask.
Deploy flow: git push -> GitHub Actions logs into Azure as a Service Principal -> builds image -> pushes to ACR -> `kubectl set image` -> rolling update.

## Tools

| Tool | Why | Note |
|---|---|---|
| Python + pip | Run the app | |
| Docker Desktop | Build/run containers | |
| Terraform | Provision Azure as code | Downloaded manually, added to Windows PATH |
| Azure CLI | Log in, query Azure | |
| kubectl | Talk to AKS | |
| Git + GitHub | Version control, trigger pipeline | |

## Build order

1. **The app.** `app.py` + `requirements.txt`, tested every route with curl. The `@app.get`/`@app.post` lines are the complete test plan.
2. **Dockerfile.** Built and ran locally before touching Azure.
3. **Terraform networking.** Resource group, VNet, subnet, NSG.
4. **Terraform ACR + AKS.** AKS inside the subnet, plus a role assignment so AKS can pull from ACR using a managed identity (no stored password).
5. **First manual deploy.** `az acr login`, tag, push, `az aks get-credentials`, `kubectl apply` for the deployment and service. First time the app was live on the internet.
6. **GitHub Actions.** A Service Principal scoped to one resource group; four repo secrets (`AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`); workflow = checkout, Azure login, build and push (tag = commit SHA), get AKS credentials, `kubectl set image`.
7. **Observability.** Log Analytics workspace, Container Insights, and an alert on pod restarts. Verified by deleting pods on purpose and waiting for the email.

## Error log: what actually went wrong

| # | Symptom | Real cause | Fix |
|---|---|---|---|
| 1 | `terraform: command not found` | Not installed / not on PATH | Downloaded the correct Windows AMD64 zip (the first was the macOS build), added to PATH, restarted terminal and PC |
| 2 | `docker build -t phoenix-api:1.0` -> requires 1 argument | Forgot the trailing `.` | `docker build -t phoenix-api:1.0 .` |
| 3 | `lookup management.azure.com: no such host` (recurring) | Unstable local network/DNS | Retry; for long applies, use a single fast `az` command instead |
| 4 | `terraform import` path mangled into `C:/Program Files/Git/subscriptions/...` | Git Bash converts arguments starting with `/` | Prefix with `MSYS_NO_PATHCONV=1` |
| 5 | `apply` on AKS: resource already exists, needs import | An earlier apply succeeded in Azure but was interrupted before saving state | Deleted the orphans with `az aks delete` / `az acr delete` and let Terraform recreate them |
| 6 | `OIDCIssuerFeatureCannotBeDisabled` | Azure enabled a feature my code never mentioned; Terraform tried to unset it | Added `oidc_issuer_enabled = true` explicitly |
| 7 | Same `upgrade_settings` diff on every plan | Azure auto-set node pool upgrade defaults | Added explicit `upgrade_settings { max_surge = "10%" }` |
| 8 | Deployed, but `curl <ip>/health` refused | NSG allowed 5000 only; the Service listens on 80 | Added an NSG rule for port 80 |
| 9 | First `git push` slow, about 53 MB | No `.gitignore`: `.venv/`, `.terraform/`, `terraform.tfstate` got committed | Wrote `.gitignore`, `git rm -r --cached` the offenders, recommitted |
| 10 | New pod in `CrashLoopBackOff` after a pipeline deploy | A bad code push | The old pod kept serving the whole time: the rolling update did its job; a corrected push fixed it |

## Verify, don't trust

A tool saying "success" isn't confirmation. The checks I used:

```
az group list -o table
az resource list -g rg-phoenix-dev -o table
az aks list -g rg-phoenix-dev -o table        # ProvisioningState: Succeeded
kubectl get nodes                             # STATUS: Ready
az acr repository show-tags --name acrphoenixdev001 --repository phoenix-api -o table
kubectl get pods                              # Running, READY 1/1; check AGE after a pipeline run
az network nsg rule list --resource-group rg-phoenix-dev --nsg-name nsg-web -o table
curl http://<public-ip>/health                # from outside Azure
terraform plan                                # "No changes" means code matches reality
```

## Concepts in one line each

- **Resource Group:** a lifecycle folder, no networking of its own.
- **NSG:** a checklist read by priority number, first match wins.
- **Pod vs node:** a pod is a running container; a node is the VM it runs on.
- **Service:** a stable address that finds whichever pods match a label; the public IP lives here.
- **Terraform state:** Terraform's memory of what it manages.
- **Managed identity vs Service Principal:** the first is an identity Azure manages for a resource; the second is a robot login for things like GitHub Actions.
- **CI/CD pipeline:** no memory between runs; it replays the whole script on a fresh machine every time.

## Not built

A real database (data resets on pod restart), a frontend, multiple replicas or autoscaling (pinned to 1 node and 1 pod for the free tier), multi-region networking, and porting a module to AWS or GCP.
