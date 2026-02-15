---
name: signing-setup
description: Configure code signing for iOS (certificates/profiles with Match) and Android (keystore)
argument-hint: "[ios|android|both]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# Code Signing Setup Command

Configure code signing for iOS and/or Android deployment.

## Parse Arguments

Extract from user input:
- **platform**: `ios`, `android`, or `both` (default: both)

## iOS Code Signing with Match

### Prerequisites
- Apple Developer Program membership
- Private Git repository for certificates
- App Store Connect API Key (recommended) or Apple ID

### Setup Steps

1. **Initialize Match**
```bash
cd ios
bundle exec fastlane match init
```

2. **Create Matchfile**
```ruby
# ios/fastlane/Matchfile
git_url("git@github.com:company/certificates.git")
storage_mode("git")
type("appstore")
app_identifier(["com.company.app"])
username("developer@company.com")
team_id("TEAM_ID")
```

3. **Generate Certificates and Profiles**
```bash
# Development
bundle exec fastlane match development

# App Store distribution
bundle exec fastlane match appstore

# Ad Hoc (for TestFlight alternatives)
bundle exec fastlane match adhoc
```

4. **Configure Xcode Project**

Update `ios/Runner.xcodeproj/project.pbxproj`:
- Set "Signing Style" to "Manual"
- Select Match-generated provisioning profiles
- Set correct Team ID

5. **CI Environment Variables**
```bash
# For GitHub Actions
MATCH_PASSWORD=<encryption-password>
MATCH_GIT_BASIC_AUTHORIZATION=<base64-encoded-credentials>

# App Store Connect API (preferred for CI)
APP_STORE_CONNECT_API_KEY_ID=<key-id>
APP_STORE_CONNECT_API_ISSUER_ID=<issuer-id>
APP_STORE_CONNECT_API_KEY_CONTENT=<key-content>
```

### Match Commands Reference
```bash
# Create new certificates (first time)
fastlane match appstore

# Use existing certificates (CI, readonly)
fastlane match appstore --readonly

# Revoke and regenerate (use with caution)
fastlane match nuke distribution
fastlane match appstore
```

## Android Code Signing

### Setup Steps

1. **Generate Upload Keystore**
```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -dname "CN=Company Name, OU=Mobile, O=Company, L=City, ST=State, C=US"
```

2. **Create key.properties**
```properties
# android/key.properties (DO NOT COMMIT)
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

3. **Update build.gradle**

Edit `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

4. **Add to .gitignore**
```
# Android signing
android/key.properties
android/*.jks
android/*.keystore
```

5. **CI Environment Setup**

Encode keystore for CI:
```bash
base64 -i android/upload-keystore.jks | pbcopy
```

GitHub Secrets:
- `KEYSTORE_BASE64` - Base64 encoded keystore
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_PASSWORD` - Key password
- `KEY_ALIAS` - Key alias (usually "upload")

### Play App Signing (Recommended)

Enable Play App Signing in Google Play Console:
1. Upload your upload key (not signing key)
2. Google manages the actual signing key
3. More secure - signing key never leaves Google

## Verification

### iOS
```bash
# List installed certificates
security find-identity -v -p codesigning

# Verify Match setup
cd ios && bundle exec fastlane match appstore --readonly
```

### Android
```bash
# Verify keystore
keytool -list -v -keystore android/upload-keystore.jks

# Test release build
flutter build appbundle --release
```

## Security Best Practices

1. **Never commit** signing credentials to Git
2. **Use environment variables** for CI/CD
3. **Rotate keys** periodically
4. **Enable Play App Signing** for Android
5. **Use Match** for iOS team certificate management
6. **Store secrets** in secure vault (GitHub Secrets, 1Password, etc.)

## Troubleshooting

### iOS Issues
- **"No signing certificate"**: Run `fastlane match appstore`
- **"Profile doesn't include signing certificate"**: Run `fastlane match nuke` then regenerate
- **Team ID mismatch**: Check Matchfile and Xcode project settings

### Android Issues
- **"Keystore was tampered with"**: Wrong password
- **"Cannot recover key"**: Key password != store password
- **Release build unsigned**: Check key.properties path
