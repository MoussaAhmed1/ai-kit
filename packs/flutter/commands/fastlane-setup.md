---
name: fastlane-setup
description: Initialize and configure Fastlane for Flutter project with iOS and Android lanes
argument-hint: "[ios|android|both]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
---

# Fastlane Setup Command

Initialize Fastlane configuration for Flutter iOS and/or Android deployment.

## Parse Arguments

Extract from user input:
- **platform**: `ios`, `android`, or `both` (default: both)

## Gather Information

Ask user for required information:

### iOS Configuration
- Apple Developer Team ID
- App Store Connect API Key (or Apple ID)
- Bundle Identifier (from `ios/Runner.xcodeproj`)
- Match repository URL (for certificates)

### Android Configuration
- Package name (from `android/app/build.gradle`)
- Google Play Console access (service account JSON path)

## Setup Steps

### 1. Install Fastlane
```bash
# Check if Fastlane installed
which fastlane || gem install fastlane

# Create Gemfile if not exists
cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "fastlane"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
EOF

bundle install
```

### 2. iOS Fastlane Setup

Create `ios/fastlane/Appfile`:
```ruby
app_identifier("com.company.app")
apple_id("developer@company.com")
team_id("TEAM_ID")
```

Create `ios/fastlane/Matchfile`:
```ruby
git_url("git@github.com:company/certificates.git")
storage_mode("git")
type("appstore")
app_identifier(["com.company.app"])
username("developer@company.com")
```

Create `ios/fastlane/Fastfile`:
```ruby
default_platform(:ios)

platform :ios do
  before_all do
    setup_ci if ENV['CI']
  end

  desc "Push to TestFlight"
  lane :beta do
    match(type: "appstore", readonly: true)
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Push to App Store"
  lane :release do
    match(type: "appstore", readonly: true)
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true
    )
  end
end
```

### 3. Android Fastlane Setup

Create `android/fastlane/Appfile`:
```ruby
json_key_file(ENV["GOOGLE_PLAY_JSON_KEY_PATH"])
package_name("com.company.app")
```

Create `android/fastlane/Fastfile`:
```ruby
default_platform(:android)

platform :android do
  desc "Deploy to internal testing"
  lane :internal do
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      json_key_data: ENV["PLAY_STORE_JSON_KEY"]
    )
  end

  desc "Promote to beta"
  lane :beta do
    upload_to_play_store(
      track: "beta",
      track_promote_to: "beta"
    )
  end

  desc "Deploy to production"
  lane :release do
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      json_key_data: ENV["PLAY_STORE_JSON_KEY"]
    )
  end
end
```

### 4. Create GitHub Actions Workflows

Create `.github/workflows/ios-deploy.yml` and `.github/workflows/android-deploy.yml` with appropriate CI/CD configuration.

## Post-Setup Instructions

After setup, inform user:

1. **iOS Match Setup** (if first time):
   ```bash
   cd ios && bundle exec fastlane match appstore
   ```

2. **Required Secrets** for GitHub Actions:
   - `MATCH_PASSWORD`
   - `MATCH_GIT_BASIC_AUTHORIZATION`
   - `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`
   - `PLAY_STORE_JSON_KEY`
   - `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`

3. **Test Locally**:
   ```bash
   cd ios && bundle exec fastlane beta
   cd android && bundle exec fastlane internal
   ```

## Verification

After setup, verify:
- [ ] `ios/fastlane/Fastfile` exists and valid
- [ ] `android/fastlane/Fastfile` exists and valid
- [ ] Gemfile includes fastlane
- [ ] Bundle install succeeds
- [ ] `fastlane lanes` shows available lanes
