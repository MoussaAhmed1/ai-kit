---
name: infisical-env-sync
description: Export and sync Infisical secrets to local .env files or other formats
argument-hint: "[dev|staging|production]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
---

# Infisical Env Sync Command

Export secrets from Infisical to local `.env` files or other formats.

## Parse Arguments

Extract from user input:
- **environment**: `dev`, `staging`, `production`, or custom (default: ask user)

## Workflow

### Step 1: Verify Authentication

```bash
# Ensure logged in
infisical user
```

If not logged in, direct user to `/infisical-auth`.

### Step 2: Gather Export Parameters

Ask user:
- **Environment**: dev, staging, production, or custom name
- **Format**: dotenv (default), json, yaml, csv
- **Secret path**: root `/` or specific folder (e.g., `/database`)
- **Output file**: `.env` (default), `.env.local`, custom path

### Step 3: Export Secrets

```bash
# Export as dotenv (default)
infisical export --env=dev > .env

# Export specific environment
infisical export --env=staging > .env.staging

# Export as JSON
infisical export --env=production --format=json > secrets.json

# Export as YAML
infisical export --env=production --format=yaml > secrets.yaml

# Export specific path
infisical export --env=production --path=/database > .env.database

# Export with self-hosted domain
infisical export --env=production --domain=https://secrets.company.com > .env
```

### Step 4: Generate .env.example

```bash
# Generate example with keys only (no values)
infisical secrets generate-example-env --env=dev > .env.example
```

### Step 5: Verify Export

```bash
# Count keys in exported file
wc -l .env

# Count keys in Infisical
infisical secrets --env=dev --silent | wc -l

# Compare counts (should match, excluding comments/blanks)
```

### Step 6: Ensure .gitignore

Verify `.env` is gitignored:
```bash
grep -q "^\.env$" .gitignore || echo ".env" >> .gitignore
grep -q "^\.env\.local$" .gitignore || echo ".env.local" >> .gitignore
grep -q "^\.env\.\*\.local$" .gitignore || echo ".env.*.local" >> .gitignore
```

## Recommendation

Prefer `infisical run` over `.env` files when possible:

```bash
# Better: inject at runtime (no file on disk)
infisical run --env=dev -- npm run dev

# Acceptable: export for tools that require .env files
infisical export --env=dev > .env
```

Using `infisical run` is preferred because:
- No secret files on disk that could be accidentally committed
- Secrets are always fresh (no stale `.env`)
- Watch mode re-injects on changes: `infisical run --watch -- npm run dev`

## Verification

- [ ] `.env` file created with correct secrets
- [ ] `.env.example` updated with current keys
- [ ] `.env` is in `.gitignore`
- [ ] Key count matches between Infisical and exported file
- [ ] No secret values in `.env.example`
