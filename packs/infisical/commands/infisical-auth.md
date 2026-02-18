---
name: infisical-auth
description: Configure Infisical authentication for development, CI/CD, or server environments
argument-hint: "[user|machine|ci]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# Infisical Auth Command

Configure authentication for Infisical based on the target context.

## Parse Arguments

Extract from user input:
- **context**: `user` (development), `machine` (server), or `ci` (pipeline)

## Workflow

### Step 1: Determine Auth Context

Ask the user which context they need authentication for:

1. **User (Development)** - Interactive login for local development
2. **Machine (Server)** - Non-interactive auth for production servers, Docker containers
3. **CI (Pipeline)** - Non-interactive auth for CI/CD pipelines

### Step 2a: User Authentication

For local development, use browser-based login:

```bash
# Default cloud
infisical login

# Self-hosted
infisical login --domain=https://secrets.company.com
```

Verify:
```bash
infisical user
infisical secrets --env=dev
```

### Step 2b: Machine Identity Authentication

For servers and long-running processes:

1. **Guide the user** to create a Machine Identity in the Infisical dashboard:
   - Go to Organization Settings > Machine Identities
   - Click "Create Identity"
   - Name it descriptively (e.g., `prod-api-server`, `staging-worker`)
   - Assign it to the project with appropriate environment access

2. **Choose auth method** based on infrastructure:

   **Universal Auth** (works everywhere):
   ```bash
   # In Infisical dashboard: Machine Identity > Authentication > Universal Auth
   # Copy Client ID and Client Secret

   infisical login --method=universal-auth \
     --client-id=<CLIENT_ID> \
     --client-secret=<CLIENT_SECRET>
   ```

   **Kubernetes Auth** (K8s pods):
   ```bash
   infisical login --method=kubernetes \
     --machine-identity-id=<MACHINE_IDENTITY_ID>
   ```

   **AWS IAM Auth** (EC2, ECS, Lambda):
   ```bash
   infisical login --method=aws-iam \
     --machine-identity-id=<MACHINE_IDENTITY_ID>
   ```

   **GCP Auth** (GCE, Cloud Run, GKE):
   ```bash
   infisical login --method=gcp-id-token \
     --machine-identity-id=<MACHINE_IDENTITY_ID>
   ```

   **Azure Auth** (VMs, AKS, Functions):
   ```bash
   infisical login --method=azure \
     --machine-identity-id=<MACHINE_IDENTITY_ID>
   ```

   **OIDC Auth** (custom identity providers):
   ```bash
   infisical login --method=oidc \
     --machine-identity-id=<MACHINE_IDENTITY_ID>
   ```

3. **Verify access**:
   ```bash
   infisical secrets --env=production
   ```

### Step 2c: CI Pipeline Authentication

For CI/CD pipelines, recommend **Universal Auth**:

1. **Create Machine Identity** in Infisical dashboard:
   - Name: `ci-github-actions` or `ci-gitlab`
   - Auth method: Universal Auth
   - Scope: Only environments needed by CI (e.g., staging, production)

2. **Store credentials in CI secrets**:

   | CI Provider | Secret Name | Value |
   |---|---|---|
   | GitHub Actions | `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` | Client ID |
   | GitHub Actions | `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET` | Client Secret |
   | GitLab CI | `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` | Client ID |
   | GitLab CI | `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET` | Client Secret |

3. **Pipeline login step**:
   ```bash
   infisical login --method=universal-auth \
     --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID \
     --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
   ```

4. **Verify in pipeline**:
   ```bash
   infisical secrets list --env=staging --silent
   ```

### Step 3: Self-Hosted Domain

If using self-hosted Infisical, ensure domain is configured:

```bash
# Via CLI flag
infisical login --domain=https://secrets.company.com --method=universal-auth ...

# Or via environment variable (recommended for CI)
export INFISICAL_API_URL=https://secrets.company.com/api
infisical login --method=universal-auth ...
```

### Step 4: Verify Authentication

Run verification:
```bash
# Check logged-in user/identity
infisical user

# Test secret access
infisical secrets --env=dev

# Test secret injection
infisical run --env=dev -- echo "Auth working"
```

## Security Recommendations

- **Rotate** machine identity credentials on a schedule (90 days recommended)
- **Scope** machine identities to minimum required environments
- **Use separate identities** per environment (don't reuse prod identity for staging)
- **Never log** client secrets in CI output
- Set `INFISICAL_DISABLE_UPDATE_CHECK=true` in CI to avoid unnecessary network calls
