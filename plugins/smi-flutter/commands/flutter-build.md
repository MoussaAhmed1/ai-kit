---
name: flutter-build
description: Build Flutter app for iOS or Android with configurable options (debug/release/profile, flavors, obfuscation)
argument-hint: "[ios|android|both] [--release|--debug|--profile] [--flavor=<name>]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
---

# Flutter Build Command

Build the Flutter application for the specified platform(s).

## Parse Arguments

Extract from user input:
- **platform**: `ios`, `android`, or `both` (default: both)
- **mode**: `--release` (default), `--debug`, or `--profile`
- **flavor**: Optional flavor/scheme name via `--flavor=<name>`
- **obfuscate**: Add `--obfuscate --split-debug-info=build/debug-info` for release builds

## Pre-Build Checks

1. Verify Flutter project exists (check for `pubspec.yaml`)
2. Run `flutter pub get` if `pubspec.lock` is outdated
3. For iOS: Check if CocoaPods needs update (`cd ios && pod install`)

## Build Commands

### Android Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Release AAB (for Play Store)
flutter build appbundle --release

# With flavor
flutter build appbundle --release --flavor production

# With obfuscation
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### iOS Build
```bash
# Debug (no code signing)
flutter build ios --debug --no-codesign

# Release (requires code signing)
flutter build ios --release

# With flavor/scheme
flutter build ios --release --flavor production

# Archive for distribution
flutter build ipa --release
```

## Execution Steps

1. Display build configuration summary
2. Run `flutter clean` if user requests clean build
3. Run `flutter pub get`
4. Execute appropriate build command(s)
5. Report build output location:
   - Android APK: `build/app/outputs/flutter-apk/`
   - Android AAB: `build/app/outputs/bundle/release/`
   - iOS: `build/ios/iphoneos/` or `build/ios/archive/`

## Error Handling

If build fails:
1. Check for common issues (missing dependencies, signing errors)
2. Suggest fixes based on error messages
3. For iOS signing issues, suggest running `/signing-setup`

## Output

Report to user:
- Build status (success/failure)
- Output file path(s)
- File size(s)
- Next steps (test locally, deploy to store)
