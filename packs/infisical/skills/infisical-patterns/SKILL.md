---
name: infisical-patterns
description: This skill activates when managing environment variables, configuring .infisical.json, organizing workspace environments, or discussing secret management patterns with Infisical CLI. It provides conventions for secret naming, folder organization, auth selection, and local development workflows.
---

# Infisical Patterns

Core patterns for managing secrets with Infisical.

## .infisical.json Convention

The `.infisical.json` file binds a project directory to an Infisical workspace:

```json
{
  "workspaceId": "abc123-def456-ghi789",
  "defaultEnvironment": "dev",
  "gitBranchToEnvironmentMapping": null
}
```

**Rules:**
- **Commit** `.infisical.json` to git (it contains no secrets, just workspace binding)
- **Do NOT commit** `.env`, `.env.local`, or any file containing secret values

## Secret Naming Convention

Use `UPPER_SNAKE_CASE` for all secret names:

```bash
# Correct
DATABASE_URL
REDIS_HOST
STRIPE_SECRET_KEY
AWS_ACCESS_KEY_ID

# Wrong
databaseUrl          # camelCase
redis-host           # kebab-case
stripe.secret.key    # dotted
```

## Folder Organization

Organize secrets into logical folders:

```
/ (root)
├── DATABASE_URL
├── REDIS_URL
├── APP_SECRET_KEY
├── /database
│   ├── DB_HOST
│   ├── DB_PORT
│   ├── DB_NAME
│   ├── DB_USER
│   └── DB_PASSWORD
├── /api-keys
│   ├── STRIPE_SECRET_KEY
│   ├── SENDGRID_API_KEY
│   └── TWILIO_AUTH_TOKEN
├── /auth
│   ├── JWT_SECRET
│   ├── OAUTH_GOOGLE_CLIENT_ID
│   ├── OAUTH_GOOGLE_CLIENT_SECRET
│   └── SESSION_SECRET
└── /third-party
    ├── SENTRY_DSN
    ├── DATADOG_API_KEY
    └── SLACK_WEBHOOK_URL
```

Access secrets from folders:
```bash
# List folder secrets
infisical secrets --env=production --path=/database

# Set secret in folder
infisical secrets set DB_HOST=db.internal --env=production --path=/database

# Run with folder secrets included
infisical run --env=production --path=/ -- npm start
```

## Local Development Pattern

### Preferred: Runtime Injection

```bash
# Inject secrets as environment variables at runtime
infisical run --env=dev -- npm run dev

# With watch mode (re-injects when secrets change in dashboard)
infisical run --watch --env=dev -- npm run dev

# With Docker Compose
infisical run --env=dev -- docker compose up
```

### Acceptable: Export to .env

When tools require a `.env` file:

```bash
# Export to .env
infisical export --env=dev > .env

# Keep .env.example up to date
infisical secrets generate-example-env --env=dev > .env.example
```

### .env.example Maintenance

Always maintain `.env.example` with descriptive comments:

```bash
# Database
DATABASE_URL=           # PostgreSQL connection string
DB_POOL_SIZE=           # Connection pool size (default: 10)

# Authentication
JWT_SECRET=             # Secret for signing JWTs
SESSION_SECRET=         # Express session secret

# External APIs
STRIPE_SECRET_KEY=      # Stripe API secret key (sk_...)
SENDGRID_API_KEY=       # SendGrid email API key
```

## Auth Pattern Selection

### Development (Interactive)

```bash
infisical login
```

### CI/CD (Machine Identity - Universal Auth)

```bash
export INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=<client-id>
export INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=<client-secret>
infisical login --method=universal-auth \
  --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID \
  --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
```

### Kubernetes (Native Auth)

```bash
infisical login --method=kubernetes \
  --machine-identity-id=$MACHINE_IDENTITY_ID
```

### Cloud Providers (Native Auth)

```bash
# AWS
infisical login --method=aws-iam --machine-identity-id=$MACHINE_IDENTITY_ID

# GCP
infisical login --method=gcp-id-token --machine-identity-id=$MACHINE_IDENTITY_ID

# Azure
infisical login --method=azure --machine-identity-id=$MACHINE_IDENTITY_ID
```

## Self-Hosted Configuration

```bash
# Via CLI flag (per-command)
infisical login --domain=https://secrets.company.com
infisical run --domain=https://secrets.company.com --env=production -- npm start

# Via environment variable (recommended for CI/servers)
export INFISICAL_API_URL=https://secrets.company.com/api
infisical login --method=universal-auth ...
infisical run --env=production -- npm start
```

## Environment Management

### Standard Environments

| Environment | Usage |
|---|---|
| `dev` | Local development |
| `staging` | Pre-production testing |
| `production` | Live production |

### Custom Environments

Create in Infisical dashboard for additional stages:
- `qa` - Quality assurance testing
- `preview` - PR preview deployments
- `demo` - Demo/sales environments

### Per-Environment Secrets

```bash
# Different values per environment
infisical secrets set DATABASE_URL=postgres://localhost/myapp_dev --env=dev
infisical secrets set DATABASE_URL=postgres://staging-db/myapp --env=staging
infisical secrets set DATABASE_URL=postgres://prod-db/myapp --env=production
```

## Anti-Patterns

### Never Commit .env Files

```gitignore
# .gitignore
.env
.env.local
.env.*.local
```

### Never Hardcode Secrets

```python
# WRONG
api_key = "sk_live_abc123"

# CORRECT
import os
api_key = os.environ["STRIPE_SECRET_KEY"]
```

### Never Use Same Secrets Across Environments

Each environment should have unique credentials. Never copy production secrets to development.

### Never Pass Secrets as CLI Arguments

```bash
# WRONG - visible in process list and shell history
./app --db-password=secret123

# CORRECT - injected as environment variables
infisical run --env=production -- ./app
```

### Never Bake Secrets into Docker Images

```dockerfile
# WRONG - secret persists in image layers
ENV API_KEY=sk_live_abc123

# CORRECT - inject at runtime
CMD ["infisical", "run", "--env=production", "--", "node", "server.js"]
```

### Never Use Overly Broad Permissions

Grant machine identities access only to the environments they need. A CI identity for staging should NOT have production access.
