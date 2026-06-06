# Week 9 Security Audit — cis410-deploy-sa

**Project:** cis410-viktor
**Date:** 2026-06-05
**Auditor:** Viktor Karatsupa

---

## 1. IAM Audit Results

### Before — Week 8 Configuration (over-permissioned)

| Role | Scope | Problem |
|---|---|---|
| roles/run.admin | Project | Overly broad — grants ability to delete services and modify IAM, not just deploy |
| roles/storage.admin | Project | Overly broad — grants access to ALL GCS buckets in the project |
| roles/artifactregistry.writer | Project | Acceptable — scoped to push images only |
| roles/viewer | Project | Acceptable — read-only project metadata |
| roles/iam.serviceAccountUser | Compute SA | Required — needed to act as Compute Engine default SA |

### After — Week 9 Least-Privilege Fix

| Role | Scope | Why Sufficient |
|---|---|---|
| roles/run.developer | Project | Deploy only — cannot delete services or modify IAM |
| roles/storage.admin | tfstate bucket only | Scoped to one bucket — not all storage |
| roles/artifactregistry.writer | Project | Unchanged — push images only |
| roles/viewer | Project | Unchanged — read project metadata |
| roles/iam.serviceAccountUser | Compute SA | Unchanged — required for Cloud Run deployment |

---

## 2. Secret Manager Migration

- **Secret created:** `flask-app-secret`
- **Replication:** automatic
- **Access granted to:** `cis410-deploy-sa@cis410-viktor.iam.gserviceaccount.com` — roles/secretmanager.secretAccessor on this secret only
- **Access granted to:** `257959833254-compute@developer.gserviceaccount.com` — roles/secretmanager.secretAccessor on this secret only (required for Cloud Run runtime access)
- **Cloud Run update:** APP_SECRET environment variable mounted from Secret Manager at runtime

---

## 3. Monitoring Configuration

- **Log-based alert:** `cis410-flask-app-alert` — fires on severity>=WARNING for cis410-flask-app
- **Notification channel:** vkarat05@gmail.com
- **Billing budget:** `cis410-monthly-budget` — $20 limit, alerts at 50% / 90% / 100%

---

## 4. Reflection

**Q1: Why is roles/run.admin inappropriate for a CI/CD pipeline service account?**

roles/run.admin grants the ability to delete services, modify traffic splits, and change IAM policies on Cloud Run services — none of which a deployment pipeline needs. A pipeline only needs to deploy new revisions, which roles/run.developer covers. Granting run.admin violates least privilege and creates risk that a compromised pipeline could take down or reconfigure production services.

---

**Q2: What is the security difference between storing a secret in GitHub Secrets vs. Google Secret Manager?**

GitHub Secrets are long-lived credentials stored in the repository that are injected as environment variables at workflow runtime — if the repo is compromised or a secret is accidentally logged, it is exposed permanently until manually rotated. Google Secret Manager stores secrets in GCP with full audit logging, fine-grained IAM, and automatic versioning, so every access is recorded and the application fetches the secret at runtime rather than at deploy time. Secret Manager also enables secret rotation without redeploying the application.

---

**Q3: A coworker says "I will clean up IAM permissions after the project launches. For now I need everything to work fast." What is the risk of this approach?**

Over-permissioned service accounts are rarely cleaned up after launch because the project moves on and the risk is invisible until an incident occurs. If the service account is compromised through a supply chain attack or leaked credential, broad roles like run.admin or storage.admin give an attacker the ability to destroy services, exfiltrate data from all buckets, or pivot to other resources. The Capital One breach demonstrated exactly this pattern — a misconfigured role with excessive permissions turned a single SSRF vulnerability into a massive data exfiltration event.
