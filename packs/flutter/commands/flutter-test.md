---
name: flutter-test
description: Run Flutter tests with coverage reporting (unit, widget, integration)
argument-hint: "[unit|widget|integration|all] [--coverage] [--update-goldens]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# Flutter Test Command

Run Flutter tests with optional coverage reporting.

## Parse Arguments

Extract from user input:
- **type**: `unit`, `widget`, `integration`, or `all` (default: all)
- **coverage**: Include `--coverage` flag
- **update-goldens**: Include `--update-goldens` for golden tests
- **filter**: Optional test file pattern

## Test Discovery

Locate tests based on type:
- **unit**: `test/unit/**/*_test.dart` or `test/**/*_test.dart` (excluding integration)
- **widget**: `test/widget/**/*_test.dart` or tests with `testWidgets`
- **integration**: `integration_test/**/*_test.dart`

## Test Commands

### Run All Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

### Run Specific Test File
```bash
flutter test test/unit/auth_test.dart
```

### Run Integration Tests
```bash
flutter test integration_test/app_test.dart
```

### Update Golden Files
```bash
flutter test --update-goldens
```

## Coverage Report

When `--coverage` is requested:

1. Run tests with coverage:
```bash
flutter test --coverage
```

2. Generate HTML report (if lcov installed):
```bash
genhtml coverage/lcov.info -o coverage/html
```

3. Report coverage summary:
```bash
lcov --summary coverage/lcov.info
```

## Execution Steps

1. Display test configuration
2. Run `flutter pub get` if needed
3. Execute test command(s)
4. Parse and display results:
   - Total tests run
   - Passed/Failed/Skipped counts
   - Failed test details
   - Coverage percentage (if enabled)

## Coverage Analysis

If coverage enabled, analyze:
- Overall line coverage percentage
- Files with low coverage (<80%)
- Uncovered critical paths

## Error Handling

If tests fail:
1. Show failed test names and locations
2. Display assertion messages
3. Suggest fixes if patterns detected

## Output Format

```
Flutter Tests Summary
=====================
Total:   150
Passed:  145
Failed:  3
Skipped: 2

Failed Tests:
- test/unit/auth_service_test.dart: 'should handle invalid credentials'
- test/widget/login_form_test.dart: 'shows error on empty email'

Coverage: 87.3% (target: 80%)
```
