# Week 8 — On-Premise Docker vs. Cloud Run Comparison

## Comparison Table

| Dimension | On-Premise Docker (Wks 3–5) | Cloud Run (Week 8) |
|---|---|---|
| Infrastructure setup | 3 VMs created, Docker installed on each | No VMs — GCP manages all infrastructure |
| Deployment command | SSH → docker build → docker run | gcloud run deploy or terraform apply |
| TLS / HTTPS | Not configured | Automatic — HTTPS provided by GCP |
| Scaling approach | Manual — redeploy or add VMs | Automatic — scales to zero and back up |
| Port management | Ports 5000/5001/5002 per environment | No port management — GCP handles routing |
| Cost when idle | VM running 24/7 regardless of traffic | Scales to zero — no cost when idle |
| Rollback | Re-deploy previous image manually | Deploy previous image tag with one command |
| Secrets management | GitHub Secrets → env vars in workflow | GitHub Secrets → env vars (OIDC replaces SSH keys) |

## Reflection Questions

**Q1: Which approach required more manual steps from push to live URL?**
On-premise Docker required significantly more manual steps: provisioning VMs, installing Docker, configuring SSH keys, building images on each VM, and managing port assignments per environment. Cloud Run eliminated VM provisioning, SSH configuration, Docker daemon management, and port management. A single gcloud run deploy command replaced the entire SSH + build + run sequence.

**Q2: How do you know which version of the code is currently running in production?**
With on-premise Docker, there was no reliable way to trace a running container back to a specific commit — images were tagged loosely or rebuilt in place. With Cloud Run and commit SHA tagging, every running revision is traceable to an exact commit in git log. The image tag d9d1d76 maps directly to a specific git commit, making audits straightforward.

**Q3: What is the security advantage of scale-to-zero beyond cost savings?**
When no instance is running, there is no attack surface exposed. A VM running 24/7 is continuously reachable, consuming memory, and potentially vulnerable to exploits even during off-hours when no legitimate traffic exists. Scale-to-zero means the container only exists when serving requests, reducing the window of exposure for any runtime vulnerabilities.

**Q4: What attack surface was eliminated by replacing SSH key secrets with OIDC?**
SSH key secrets stored in GitHub are long-lived credentials — if leaked through a log, PR comment, or accidental commit, they provide permanent access. OIDC tokens are short-lived and scoped to a single workflow run. There is no stored credential to rotate, leak, or revoke. The entire class of credential-theft attacks against stored secrets is eliminated.
