---
name: flutter-deploy
description: Deploy Flutter app to App Store or Google Play using Fastlane
argument-hint: "[ios|android] [testflight|appstore|internal|beta|production]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Flutter Deploy Command

Deploy the Flutter application to app stores using Fastlane.

## Parse Arguments

Extract from user input:
- **platform**: `ios` or `android` (required)
- **target**:
  - iOS: `testflight` (default) or `appstore`
  - Android: `internal` (default), `beta`, or `production`

## Pre-Deploy Validation

Before deploying, verify:

1. **Version Check**: Confirm version bumped in `pubspec.yaml`
2. **Changelog**: Verify CHANGELOG.md updated
3. **Tests**: Run `flutter test` and ensure passing
4. **Fastlane Setup**: Verify Fastlane configured (`ios/fastlane/` or `android/fastlane/`)
5. **Code Signing**:
   - iOS: Match configured and certificates valid
   - Android: Keystore configured in `key.properties`

## iOS Deployment

### TestFlight
```bash
# Build Flutter
flutter build ios --release

# Deploy via Fastlane
cd ios && bundle exec fastlane beta
```

### App Store
```bash
# Build Flutter
flutter build ipa --release

# Deploy via Fastlane
cd ios && bundle exec fastlane release
```

## Android Deployment

### Internal Testing
```bash
# Build AAB
flutter build appbundle --release

# Deploy via Fastlane
cd android && bundle exec fastlane internal
```

### Beta Track
```bash
cd android && bundle exec fastlane beta
```

### Production
```bash
cd android && bundle exec fastlane release
```

## Execution Steps

1. **Validate Prerequisites**
   - Check Fastlane installation
   - Verify credentials/secrets configured
   - Confirm version and changelog

2. **Build Application**
   - Run appropriate `flutter build` command
   - Verify build succeeds

3. **Execute Fastlane Lane**
   - Navigate to platform directory
   - Run `bundle exec fastlane <lane>`
   - Monitor upload progress

4. **Post-Deploy Actions**
   - Report deployment status
   - Provide store console links
   - Suggest next steps (submit for review, promote track)

## Environment Variables Required

### iOS (App Store Connect)
- `MATCH_PASSWORD`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`

### Android (Google Play)
- `PLAY_STORE_JSON_KEY`

## Error Handling

Common issues and fixes:
- **Code signing failed**: Run `/signing-setup`
- **Version already exists**: Bump version in `pubspec.yaml`
- **Missing metadata**: Update store metadata in `fastlane/metadata/`
- **API credentials invalid**: Check environment variables

## Output

Report to user:
- Deployment status
- Build number uploaded
- Store console URL
- Estimated review time (if applicable)
- Next steps

## Post-Deploy Checklist

- [ ] Verify build appears in store console
- [ ] Check release notes are correct
- [ ] Monitor for processing completion
- [ ] Submit for review (if App Store)
- [ ] Promote to wider audience (if Play Store)
