---
name: infisical-init
description: Initialize a project with Infisical secret management - install CLI, configure workspace, and set up .gitignore
argument-hint: "[cloud|self-hosted]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
---

# Infisical Init Command

Initialize Infisical secret management for the current project.

## Parse Arguments

Extract from user input:
- **mode**: `cloud` or `self-hosted` (default: ask user)

## Gather Information

### Step 1: Check CLI Installation

```bash
# Check if infisical CLI is installed
which infisical && infisical --version
```

If not installed, provide installation instructions:

```bash
# macOS
brew install infisical/get-cli/infisical

# Linux (Debian/Ubuntu)
curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
sudo apt-get update && sudo apt-get install -y infisical

# Linux (RPM)
curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.rpm.sh' | sudo -E bash
sudo yum install -y infisical

# npm (any platform)
npm install -g @infisical/cli

# Docker
docker pull infisical/cli
```

Ask user to install and confirm before proceeding.

### Step 2: Determine Instance Type

Ask user:
- **Cloud**: `app.infisical.com` (default) or EU region `eu.infisical.com`
- **Self-hosted**: Custom domain (e.g., `https://secrets.company.com`)

### Step 3: Authenticate

```bash
# Cloud (default)
infisical login

# Cloud (EU region)
infisical login --domain=https://eu.infisical.com

# Self-hosted
infisical login --domain=https://secrets.company.com
```

### Step 4: Initialize Project

```bash
# Creates .infisical.json with workspace/project binding
infisical init
```

This will prompt the user to select their organization and project in the terminal.

### Step 5: Verify Connection

```bash
# Test that secrets are accessible
infisical secrets --env=dev
```

### Step 6: Generate .env.example

```bash
# Generate example env file with keys (no values)
infisical secrets generate-example-env --env=dev > .env.example
```

### Step 7: Update .gitignore

Check and update `.gitignore` to include:

```
# Infisical
.env
.env.local
.env.*.local

# Keep .env.example committed
!.env.example
```

Do NOT add `.infisical.json` to `.gitignore` - it should be committed so team members can use the same workspace binding.

### Step 8: Confirm Setup

Verify the following files exist:
- [ ] `.infisical.json` - workspace binding (commit this)
- [ ] `.env.example` - secret keys reference (commit this)
- [ ] `.gitignore` - excludes `.env` files

## Post-Setup Instructions

After initialization, inform user:

1. **Team members** can run `infisical login` and secrets will resolve via `.infisical.json`
2. **Local development**: Use `infisical run -- <command>` to inject secrets
3. **CI/CD**: Set up machine identity with `/infisical-auth`
4. **Scan for leaks**: Run `/infisical-scan` to check for hardcoded secrets

## Example Usage

```bash
# Start dev server with secrets injected
infisical run -- npm run dev

# Start with watch mode (re-inject on secret changes)
infisical run --watch -- npm run dev

# Use specific environment
infisical run --env=staging -- npm run dev
```
