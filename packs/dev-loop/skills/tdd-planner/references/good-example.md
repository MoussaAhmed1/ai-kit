# Good Plan Example: Flutter Riverpod Migration

This is a reference example of a well-structured dev-loop plan. Use this as a quality benchmark when generating plans.

---

## What Makes This Plan Good

1. **Specific Context** - Lists exact providers to migrate, not just "migrate to Riverpod"
2. **Measurable Criteria** - "81+ tests", "No Provider imports remain"
3. **File Paths** - Every task mentions exact file paths
4. **Code Snippets** - Shows actual implementation structure
5. **Expected Behavior** - "should FAIL (providers don't exist yet)"
6. **Tables** - Files to Modify + New Files to Create
7. **Framework-Specific** - Uses Flutter/Dart patterns correctly
8. **Stuck Handling** - Specific to Riverpod, not generic

---

## The Plan

```markdown
# Dev Loop Plan: Migrate to Riverpod State Management

## Context
- **Framework**: Flutter
- **Current State Management**: Provider with ChangeNotifierProvider
- **Test Command**: `flutter test`
- **Lint Command**: `flutter analyze`
- **Providers to Migrate**:
  - `AppStateProvider` (settings, prayer reminders)
  - `NetworkService` (connectivity status)
  - `SyncService` (cloud sync status)

## Success Criteria
- [ ] All existing tests pass (81+ tests)
- [ ] `flutter analyze` shows no issues
- [ ] App starts correctly with ProviderScope
- [ ] Settings load and persist correctly
- [ ] Network status updates reactively
- [ ] Sync status updates reactively
- [ ] No Provider imports remain (clean migration)

---

## Phase 1: Red - Setup and Infrastructure Tests

**Goal:** Add Riverpod dependency and write failing tests for core providers

**Tasks:**
- [ ] Add `flutter_riverpod` to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Create `test/providers/app_state_provider_test.dart` with failing tests
- [ ] Create `test/providers/network_provider_test.dart` with failing tests

**Verification:** `flutter test test/providers/` should FAIL (providers don't exist yet)

**Expected Output:** Test failures because Riverpod providers not implemented

**Self-correction:** If tests pass, they are not testing the right thing - add assertions

---

## Phase 2: Green - Implement Core Providers

**Goal:** Create Riverpod providers that pass the tests

**Tasks:**
- [ ] Create `lib/providers/app_state_provider.dart` with StateNotifierProvider
- [ ] Create `lib/providers/network_provider.dart` with StateNotifierProvider
- [ ] Create `lib/providers/sync_provider.dart` with StateNotifierProvider
- [ ] Create `lib/providers/providers.dart` barrel file

**Provider Structure:**
```dart
// App State
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

// Network
final networkProvider = StateNotifierProvider<NetworkNotifier, NetworkState>((ref) {
  return NetworkNotifier();
});

// Sync (depends on network)
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final network = ref.watch(networkProvider);
  return SyncNotifier(isOnline: network.isOnline);
});
```

**Verification:** `flutter test test/providers/` should PASS

**Self-correction:** If tests still fail, check state classes match expected structure

---

## Phase 3: Red - Widget Migration Tests

**Goal:** Write failing tests for widget provider consumption

**Tasks:**
- [ ] Update `test/widget_test.dart` to use ProviderScope
- [ ] Add test for PrayerTimesScreen with Riverpod
- [ ] Add test for OfflineIndicator with network provider

**Verification:** `flutter test test/widget_test.dart` should FAIL

**Self-correction:** Ensure test wraps widgets in ProviderScope

---

## Phase 4: Green - Migrate main.dart and Widgets

**Goal:** Replace MultiProvider with ProviderScope and migrate widgets

**Tasks:**
- [ ] Update `lib/main.dart`:
  - Replace `MultiProvider` with `ProviderScope`
  - Remove old Provider imports
  - Add Riverpod imports
- [ ] Migrate `lib/screens/prayer_times_screen.dart`:
  - Change to ConsumerStatefulWidget
  - Replace `context.watch<>` with `ref.watch()`
  - Replace `context.read<>` with `ref.read()`
- [ ] Migrate `lib/widgets/offline_indicator.dart`:
  - Replace Provider consumption with Riverpod
- [ ] Migrate `lib/screens/notification_settings_screen.dart`:
  - Replace Provider consumption with Riverpod

**Verification:** `flutter test` should PASS

**Self-correction:** If widget tests fail, verify ConsumerWidget/ConsumerStatefulWidget usage

---

## Phase 5: Refactor - Clean Up Old Provider Code

**Goal:** Remove old Provider code and ensure clean architecture

**Tasks:**
- [ ] Delete or rename old `lib/services/app_state_provider.dart`
- [ ] Remove `provider` package from pubspec.yaml (if no longer needed)
- [ ] Update all remaining imports
- [ ] Run `flutter analyze` to catch any issues
- [ ] Update CLAUDE.md documentation

**Verification:**
```bash
flutter analyze && flutter test
```

**Self-correction:** If analyze shows errors, fix import paths

---

## Phase 6: Integration Testing

**Goal:** Verify full app works end-to-end

**Tasks:**
- [ ] Run app on simulator/device
- [ ] Verify settings load correctly
- [ ] Verify offline indicator works
- [ ] Verify sync status updates
- [ ] Verify prayer times screen works
- [ ] Test hot reload works

**Verification:** Manual testing + all automated tests pass

**Self-correction:** If app crashes, check initialization order in main.dart

---

## Final Verification

```bash
flutter analyze && flutter test
```

**Expected Results:**
- `flutter analyze`: No issues found!
- `flutter test`: All tests passed!

---

## Completion

When all criteria met: <promise>DONE</promise>

---

## Stuck Handling

### If same test keeps failing:
1. Read the exact error message
2. Check if state class matches test expectations
3. Verify ref.watch vs ref.read usage
4. Check ProviderScope is at root

### If app won't start:
1. Check ProviderScope wraps entire app
2. Verify no circular dependencies in providers
3. Check async initialization is handled

### If hot reload breaks:
1. ConsumerStatefulWidget may need widget rebuild
2. Check provider isn't being disposed incorrectly

### Alternative approaches if blocked:
1. Keep hybrid approach (both Provider and Riverpod) temporarily
2. Migrate one screen at a time
3. Use ChangeNotifierProvider adapter in Riverpod for gradual migration

---

## Files to Modify

| File | Action |
|------|--------|
| `pubspec.yaml` | Add flutter_riverpod |
| `lib/main.dart` | Replace MultiProvider with ProviderScope |
| `lib/services/app_state_provider.dart` | Migrate to Riverpod or delete |
| `lib/services/network_service.dart` | Keep service, add Riverpod wrapper |
| `lib/services/sync_service.dart` | Keep service, add Riverpod wrapper |
| `lib/screens/prayer_times_screen.dart` | Use ConsumerStatefulWidget |
| `lib/widgets/offline_indicator.dart` | Use Consumer/ConsumerWidget |
| `lib/screens/notification_settings_screen.dart` | Use Consumer/ConsumerWidget |
| `test/widget_test.dart` | Wrap in ProviderScope |

---

## New Files to Create

| File | Purpose |
|------|---------|
| `lib/providers/providers.dart` | Barrel file for all providers |
| `lib/providers/app_state_provider.dart` | Riverpod app state |
| `lib/providers/network_provider.dart` | Riverpod network state |
| `lib/providers/sync_provider.dart` | Riverpod sync state |
| `test/providers/app_state_provider_test.dart` | Provider tests |
| `test/providers/network_provider_test.dart` | Provider tests |
```

---

## Checklist for Quality Plans

Use this checklist when reviewing generated plans:

- [ ] **Context** lists specific items to work on (not just "the feature")
- [ ] **Success Criteria** are measurable (numbers, specific behaviors)
- [ ] **Every task** has a file path
- [ ] **Code snippets** show implementation structure
- [ ] **Verification** has expected output (PASS/FAIL + why)
- [ ] **Self-correction** is phase-specific, not generic
- [ ] **Files to Modify** table exists
- [ ] **New Files to Create** table exists
- [ ] **Stuck Handling** is framework/task-specific
