# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
flutter pub get                          # Install dependencies
dart run build_runner build              # Generate Drift database code (run after changing tables.dart)
flutter run                              # Run on connected device/emulator
flutter run -d macos                     # Run on macOS desktop
flutter run -d chrome                    # Run on web (if supported)
```

## Testing

```bash
flutter test                             # Run all tests
flutter test test/sm2_test.dart          # Run a single test file
flutter analyze                          # Static analysis (uses analysis_options.yaml)
```

## Architecture

This is an English vocabulary learning app that lets users watch videos with subtitles and tap words to look them up and save them for spaced-repetition review.

### Layer Structure

- **`lib/core/`** — Framework-level utilities: SM2 spaced-repetition algorithm, SRT/VTT subtitle parser, GoRouter config, theme
- **`lib/data/`** — Persistence layer: Drift (SQLite) database with generated code, domain models (`SubtitleCue`, `WordDefinition`), repositories that wrap DB operations
- **`lib/services/`** — Business logic providers: video player management (media_kit), dictionary lookup (Free Dictionary API with local cache), screenshot capture
- **`lib/presentation/`** — UI screens organized by feature: `home/`, `player/`, `library/`, `review/`

### State Management

Riverpod throughout. Providers are defined near the classes they expose (e.g., `databaseProvider` in `database_provider.dart`, `playerNotifierProvider` in `player_service.dart`). The player uses `StateNotifier`; simpler state uses `StateProvider`.

### Database (Drift)

Tables defined in `lib/data/database/tables.dart`. The generated file `app_database.g.dart` must be regenerated with `dart run build_runner build` after schema changes. Schema version is in `app_database.dart` — increment `schemaVersion` and add migration logic when modifying tables.

### Key Data Flow

1. User imports a video → `VideoRepository` saves metadata to `Videos` table, generates thumbnail
2. User opens video → `PlayerNotifier` loads the video via media_kit, parses SRT subtitles into `SubtitleCue` list, syncs active cue to playback position via binary search
3. User taps a word in the subtitle overlay → `DictionaryService` looks up definition (cache-first, then Free Dictionary API), shows `WordPopup`
4. User saves word → `WordRepository` creates a `WordCards` entry with definition JSON, video context, and screenshot
5. User reviews → `ReviewScreen` fetches due cards, user grades recall, `SM2.calculate()` updates scheduling fields

### External Dependencies

- **media_kit** — Video playback engine (requires `MediaKit.ensureInitialized()` before runApp)
- **Drift** — SQLite ORM with code generation
- **Free Dictionary API** (`api.dictionaryapi.dev`) — English word definitions, no auth required

### UI Language

The app UI is in Chinese (Simplified). Button labels, navigation, and user-facing strings are in Chinese.
