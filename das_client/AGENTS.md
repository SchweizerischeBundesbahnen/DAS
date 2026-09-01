# DAS Client – Agent Guide

## Project

Flutter mobile app (Driver Advisory System) for train drivers. Tablet-only (≥11"), Android & iOS. See `README.md`
for full product and setup docs.

## Monorepo

Dart workspace managed with Melos (`fvm dart run melos <script>`). Each top-level directory is a package, see
`components.puml` for the dependency diagram. Every package has its own `AGENTS.md` — read it before working inside that
package.

## Key commands

```sh
fvm dart run melos generate   # build_runner + flutter gen-l10n — run after model/l10n changes
fvm dart run melos test       # unit tests across all packages
cd app && fvm flutter run --flavor dev -t lib/main_dev.dart
```

## Deeper guidance

Loaded on demand — open the linked file only once the task actually touches that area:

- Writing or formatting Dart code → `CODING_STANDARDS.md`
- Designing ViewModels, repositories, or services → `docs/ARCHITECTURE.md`
- Writing or reviewing unit tests → `docs/UNIT_TESTING.md`
- Writing or reviewing integration tests → `docs/INTEGRATION_TESTING.md`
- Adding or changing user-facing strings → `README.md#localization`
- Editing `@JsonSerializable`/drift models or ARB files → `docs/CODE_GENERATION.md`
- Scaffolding a new workspace package, REST API service, or ViewModel → skills in `.agents/skills/`
  (`dart-workspace-component`, `dart-rest-api-service`, `flutter-view-model`)
