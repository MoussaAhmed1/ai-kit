---
name: infisical-scan
description: Scan codebase for exposed secrets and hardcoded credentials
argument-hint: "[directory|git-history|staged]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
---

# Infisical Scan Command

Scan the codebase for exposed secrets, API keys, and hardcoded credentials.

## Parse Arguments

Extract from user input:
- **mode**: `directory` (default), `git-history`, or `staged`

## Workflow

### Step 1: Check CLI Available

```bash
which infisical && infisical --version
```

### Step 2: Choose Scan Mode

Ask the user which scan to run:

1. **Directory Scan** - Scan all files in current directory
2. **Git History Scan** - Scan git commit history for leaked secrets
3. **Staged Only** - Scan only staged files (pre-commit check)

### Step 3a: Directory Scan

```bash
# Scan current directory
infisical scan

# Scan specific path
infisical scan --path=./src

# Scan with verbose output
infisical scan -v
```

### Step 3b: Git History Scan

```bash
# Scan all git history
infisical scan git-changes

# Scan recent changes only
infisical scan git-changes --staged
```

### Step 3c: Staged Files Only

```bash
# Scan only staged files (ideal for pre-commit)
infisical scan git-changes --staged
```

### Step 4: Analyze Results

Review scan output and categorize findings by severity:

- **Critical**: AWS keys, database connection strings, private keys, tokens with write access
- **High**: API keys, OAuth secrets, webhook secrets
- **Medium**: Internal URLs, non-production credentials
- **Low**: Example/placeholder values that look like secrets

### Step 5: Remediate Findings

For each real secret found:

1. **Move to Infisical**:
   ```bash
   infisical secrets set LEAKED_KEY=<actual-value> --env=dev
   ```

2. **Remove from code** and replace with environment variable:
   ```python
   # Before (hardcoded)
   api_key = "sk_live_abc123"

   # After (from environment)
   api_key = os.environ["API_KEY"]
   ```

3. **Rotate the credential** - any secret found in git history should be considered compromised:
   - Regenerate the key/token in the provider's dashboard
   - Update the new value in Infisical
   - Revoke the old credential

4. **Verify cleanup**:
   ```bash
   infisical scan
   ```

### Step 6: Set Up Pre-Commit Hook (Optional)

Ask user if they want to install automatic scanning:

```bash
# Install pre-commit hook
infisical scan install --pre-commit-hook
```

This adds a git pre-commit hook that runs `infisical scan git-changes --staged` before every commit.

Alternative using `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: local
    hooks:
      - id: infisical-scan
        name: Infisical Secret Scan
        entry: infisical scan git-changes --staged
        language: system
        pass_filenames: false
```

## Post-Scan Instructions

1. **All findings remediated**: Secrets moved to Infisical and rotated
2. **Pre-commit hook installed**: Future commits are automatically scanned
3. **Run periodically**: Schedule `infisical scan git-changes` in CI pipelines
4. Use `/infisical-env-sync` to export clean `.env.example` files

## Verification

- [ ] No critical/high findings in scan output
- [ ] Exposed secrets rotated at the source
- [ ] Secrets stored in Infisical
- [ ] Code references environment variables instead of hardcoded values
- [ ] Pre-commit hook installed (optional)
