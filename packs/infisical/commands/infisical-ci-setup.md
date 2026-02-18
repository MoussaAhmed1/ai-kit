---
name: infisical-ci-setup
description: Generate CI/CD pipeline configuration for Infisical secret injection
argument-hint: "[github|gitlab|circleci|jenkins|bitbucket]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
---

# Infisical CI Setup Command

Generate CI/CD pipeline configuration for injecting Infisical secrets into builds and deployments.

## Parse Arguments

Extract from user input:
- **provider**: `github`, `gitlab`, `circleci`, `jenkins`, or `bitbucket`

## Workflow

### Step 1: Determine CI Provider

Ask user which CI/CD provider they use:
1. GitHub Actions
2. GitLab CI
3. CircleCI
4. Jenkins
5. Bitbucket Pipelines

### Step 2: Create Machine Identity

Guide user through Infisical dashboard:

1. Go to **Organization Settings > Machine Identities**
2. Click **Create Identity**
3. Name: `ci-<provider>-<project>` (e.g., `ci-github-myapp`)
4. Add **Universal Auth** method
5. Copy **Client ID** and **Client Secret**
6. Add identity to the project with access to required environments

### Step 3: Store Credentials in CI

Guide user to add these secrets to their CI provider:

| Secret Name | Value |
|---|---|
| `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID` | Client ID from step 2 |
| `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET` | Client Secret from step 2 |

For self-hosted, also add:
| `INFISICAL_API_URL` | `https://secrets.company.com/api` |

### Step 4: Generate Pipeline Config

#### GitHub Actions

Create `.github/workflows/deploy.yml` (or add to existing):

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Infisical CLI
        run: |
          curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
          sudo apt-get update && sudo apt-get install -y infisical

      - name: Authenticate with Infisical
        run: |
          infisical login --method=universal-auth \
            --client-id=${{ secrets.INFISICAL_UNIVERSAL_AUTH_CLIENT_ID }} \
            --client-secret=${{ secrets.INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET }}
        env:
          INFISICAL_DISABLE_UPDATE_CHECK: "true"

      - name: Build with secrets
        run: infisical run --env=production -- npm run build

      - name: Deploy
        run: infisical run --env=production -- npm run deploy
```

#### GitLab CI

Add to `.gitlab-ci.yml`:

```yaml
variables:
  INFISICAL_DISABLE_UPDATE_CHECK: "true"

.infisical-setup: &infisical-setup
  before_script:
    - curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | bash
    - apt-get update && apt-get install -y infisical
    - infisical login --method=universal-auth
        --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
        --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET

deploy:
  stage: deploy
  <<: *infisical-setup
  script:
    - infisical run --env=production -- npm run build
    - infisical run --env=production -- npm run deploy
  only:
    - main
```

#### CircleCI

Add to `.circleci/config.yml`:

```yaml
version: 2.1

jobs:
  deploy:
    docker:
      - image: cimg/node:20.0
    steps:
      - checkout
      - run:
          name: Install Infisical CLI
          command: |
            curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
            sudo apt-get update && sudo apt-get install -y infisical
      - run:
          name: Authenticate
          command: |
            infisical login --method=universal-auth \
              --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID \
              --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
          environment:
            INFISICAL_DISABLE_UPDATE_CHECK: "true"
      - run:
          name: Build and Deploy
          command: |
            infisical run --env=production -- npm run build
            infisical run --env=production -- npm run deploy

workflows:
  deploy:
    jobs:
      - deploy:
          filters:
            branches:
              only: main
```

#### Jenkins

Add to `Jenkinsfile`:

```groovy
pipeline {
    agent any

    environment {
        INFISICAL_DISABLE_UPDATE_CHECK = 'true'
        INFISICAL_UNIVERSAL_AUTH_CLIENT_ID = credentials('infisical-client-id')
        INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET = credentials('infisical-client-secret')
    }

    stages {
        stage('Setup Infisical') {
            steps {
                sh '''
                    curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
                    sudo apt-get update && sudo apt-get install -y infisical
                    infisical login --method=universal-auth \
                        --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID \
                        --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
                '''
            }
        }

        stage('Build') {
            steps {
                sh 'infisical run --env=production -- npm run build'
            }
        }

        stage('Deploy') {
            steps {
                sh 'infisical run --env=production -- npm run deploy'
            }
        }
    }
}
```

#### Bitbucket Pipelines

Add to `bitbucket-pipelines.yml`:

```yaml
pipelines:
  branches:
    main:
      - step:
          name: Deploy
          script:
            - curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | bash
            - apt-get update && apt-get install -y infisical
            - infisical login --method=universal-auth
                --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
                --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
            - export INFISICAL_DISABLE_UPDATE_CHECK=true
            - infisical run --env=production -- npm run build
            - infisical run --env=production -- npm run deploy
```

### Step 5: Docker Integration

If the project uses Docker, provide container patterns:

```dockerfile
# Multi-stage build: export secrets at build time
FROM node:20-alpine AS builder
RUN apk add --no-cache curl bash && \
    curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.rpm.sh' | bash && \
    apk add infisical

ARG INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
ARG INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
ENV INFISICAL_DISABLE_UPDATE_CHECK=true

RUN infisical login --method=universal-auth \
    --client-id=$INFISICAL_UNIVERSAL_AUTH_CLIENT_ID \
    --client-secret=$INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET

COPY . .
RUN infisical run --env=production -- npm run build

# Runtime: no secrets baked in
FROM node:20-alpine
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

Runtime injection (preferred):
```bash
# Inject at container start, not build time
docker run -e INFISICAL_UNIVERSAL_AUTH_CLIENT_ID=... \
           -e INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET=... \
           myapp infisical run --env=production -- node server.js
```

## Verification

After setup, verify in CI:
- [ ] Infisical CLI installs successfully in pipeline
- [ ] Authentication succeeds with machine identity
- [ ] Secrets are injected into build/deploy commands
- [ ] No secret values appear in CI logs
- [ ] Pipeline completes successfully end-to-end
