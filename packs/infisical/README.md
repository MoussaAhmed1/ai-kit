# infisical

Claude Code plugin for **Infisical** - the open-source secret management platform. Provides CLI operations, authentication, secret scanning, environment sync, and CI/CD integration for cloud and self-hosted instances.

## Features

- **1 Specialized Agent** for secret management operations
- **5 Commands** for initialization, auth, scanning, env sync, and CI/CD setup
- **3 Auto-activating Skills** for Infisical patterns, CI integration, and secret hygiene
- **Cloud & Self-hosted** support for Infisical instances

## Installation

```bash
# Add Smicolon marketplace (if not already added)
/plugin marketplace add https://github.com/smicolon/ai-kit

# Install the plugin
/plugin install infisical
```

## Agent

| Agent | Description |
|-------|-------------|
| `@infisical-ops` | Secret management operations, auth configuration, CLI guidance, CI/CD integration |

### Usage

```bash
@infisical-ops "Set up Infisical for our Django project with GitHub Actions CI"
@infisical-ops "Configure machine identity for Kubernetes production deployment"
@infisical-ops "Organize secrets into folders for our microservices"
@infisical-ops "Debug authentication failure on self-hosted instance"
```

## Commands

| Command | Description |
|---------|-------------|
| `/infisical-init` | Initialize project with Infisical (install CLI, configure workspace) |
| `/infisical-auth` | Configure authentication (user, machine, or CI context) |
| `/infisical-scan` | Scan codebase for exposed secrets and hardcoded credentials |
| `/infisical-env-sync` | Export/sync secrets to .env files or other formats |
| `/infisical-ci-setup` | Generate CI/CD pipeline configs (GitHub, GitLab, CircleCI, Jenkins, Bitbucket) |

### Usage

```bash
/infisical-init
/infisical-auth ci
/infisical-scan git-history
/infisical-env-sync production
/infisical-ci-setup github
```

## Skills (Auto-activating)

These skills automatically activate based on context:

| Skill | Triggers When |
|-------|---------------|
| `infisical-patterns` | Managing env vars, configuring .infisical.json, organizing environments |
| `infisical-ci-integration` | Writing CI/CD configs, Dockerfiles, K8s manifests needing secrets |
| `secret-hygiene` | Detecting hardcoded secrets, creating .env files, env var references |

## Conventions Enforced

### Secret Naming

```bash
# UPPER_SNAKE_CASE for all secret names
DATABASE_URL
STRIPE_SECRET_KEY
AWS_ACCESS_KEY_ID
```

### Folder Organization

```
/ (root)
├── DATABASE_URL
├── /database
│   ├── DB_HOST
│   └── DB_PASSWORD
├── /api-keys
│   ├── STRIPE_SECRET_KEY
│   └── SENDGRID_API_KEY
└── /auth
    ├── JWT_SECRET
    └── SESSION_SECRET
```

### Runtime Injection (Preferred)

```bash
# Preferred: inject at runtime
infisical run --env=dev -- npm run dev

# Acceptable: export when tools require .env
infisical export --env=dev > .env
```

### Authentication Methods

| Context | Method |
|---------|--------|
| Local dev | `infisical login` (browser) |
| CI/CD | Universal Auth (client ID + secret) |
| Kubernetes | Kubernetes Auth (service account) |
| AWS | AWS IAM Auth |
| GCP | GCP Auth |
| Azure | Azure Auth |

## Supported Platforms

- **Cloud**: app.infisical.com, eu.infisical.com
- **Self-hosted**: Any custom domain

### CI/CD Providers

- GitHub Actions
- GitLab CI
- CircleCI
- Jenkins
- Bitbucket Pipelines

### Deployment Targets

- Docker / Docker Compose
- Kubernetes
- AWS (Lambda, ECS, EC2)
- GCP (Cloud Run, GKE, GCE)
- Azure (Functions, AKS)
- Vercel
- Cloudflare Workers

## Requirements

- Infisical CLI installed (`brew install infisical/get-cli/infisical`)
- Infisical account (cloud or self-hosted)
- Project created in Infisical dashboard
