# smi-flutter

Flutter development plugin with Fastlane automation, store publishing, and architecture patterns.

## Features

- **Flutter Architecture**: Feature-first project structure, clean architecture, state management (Bloc/Riverpod/Provider)
- **Fastlane Automation**: Pre-configured lanes for iOS and Android deployment
- **Store Publishing**: Automated submission to App Store and Google Play
- **Code Signing**: Match for iOS, keystore management for Android
- **CI/CD**: GitHub Actions workflows for automated releases

## Installation

```bash
# Add marketplace (if not already added)
/plugin marketplace add https://github.com/smicolon/claude-infra

# Install plugin
/plugin install smi-flutter
```

## Components

### Agents (3)

| Agent | Description |
|-------|-------------|
| `@flutter-architect` | Design app architecture, state management, feature structure |
| `@flutter-builder` | Implement Flutter features with best practices |
| `@release-manager` | Manage releases, versioning, and store submissions |

### Commands (5)

| Command | Description |
|---------|-------------|
| `/flutter-build` | Build app for iOS/Android |
| `/flutter-test` | Run tests with coverage |
| `/flutter-deploy` | Deploy to App Store or Google Play |
| `/fastlane-setup` | Initialize Fastlane configuration |
| `/signing-setup` | Configure code signing |

### Skills (3)

| Skill | Auto-triggers when... |
|-------|----------------------|
| `flutter-architecture` | Designing Flutter app structure or choosing state management |
| `fastlane-knowledge` | Setting up deployment automation or CI/CD |
| `store-publishing` | Preparing for App Store or Google Play submission |

## Quick Start

### New Flutter Project

```bash
# Design architecture
@flutter-architect "Design a new e-commerce Flutter app with user auth, product catalog, and cart"

# Set up Fastlane
/fastlane-setup both

# Configure code signing
/signing-setup both
```

### Development Workflow

```bash
# Implement features
@flutter-builder "Implement the user authentication feature with email/password login"

# Run tests
/flutter-test --coverage

# Build for testing
/flutter-build android --release
```

### Release Workflow

```bash
# Prepare release
@release-manager "Prepare version 1.2.0 release with new cart feature"

# Deploy to TestFlight
/flutter-deploy ios testflight

# Deploy to Play Store internal testing
/flutter-deploy android internal

# Promote to production
/flutter-deploy ios appstore
/flutter-deploy android production
```

## Project Structure

The plugin enforces feature-first project organization:

```
lib/
├── core/                    # Shared utilities
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── theme/
├── features/                # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── [other_features]/
├── shared/                  # Shared widgets
└── main.dart
```

## State Management

The plugin supports multiple state management solutions:

- **Bloc** (recommended for enterprise): Explicit state transitions, excellent testability
- **Riverpod** (recommended for modern apps): Compile-safe, flexible DI
- **Provider** (recommended for simple apps): Easy to learn, good for smaller projects

## CI/CD with GitHub Actions

After running `/fastlane-setup`, the plugin creates GitHub Actions workflows:

- `.github/workflows/ios-deploy.yml` - iOS TestFlight/App Store deployment
- `.github/workflows/android-deploy.yml` - Android Play Store deployment

### Required GitHub Secrets

#### iOS
- `MATCH_PASSWORD` - Match encryption password
- `MATCH_GIT_BASIC_AUTHORIZATION` - Git credentials for certificate repo
- `ASC_KEY_ID` - App Store Connect API Key ID
- `ASC_ISSUER_ID` - App Store Connect Issuer ID
- `ASC_KEY_CONTENT` - App Store Connect API Key content

#### Android
- `PLAY_STORE_JSON_KEY` - Google Play service account JSON
- `KEYSTORE_BASE64` - Base64 encoded keystore
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_PASSWORD` - Key password
- `KEY_ALIAS` - Key alias

## Pre-Deploy Validation

The plugin includes a hook that validates before deployment:
- Version bumped in `pubspec.yaml`
- `CHANGELOG.md` updated
- Tests passing
- Code signing configured

## Requirements

- Flutter SDK 3.x
- Ruby (for Fastlane)
- Xcode (for iOS builds)
- Android Studio (for Android builds)
- Apple Developer Program membership (for iOS deployment)
- Google Play Developer account (for Android deployment)

## Related Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Fastlane Documentation](https://docs.fastlane.tools)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Google Play Console](https://play.google.com/console)
