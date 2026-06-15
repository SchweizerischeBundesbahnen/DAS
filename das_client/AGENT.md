# DAS Client – Agent Guide

## Project
Flutter mobile app (Driver Advisory System) for train drivers. Tablet-only (≥11"), Android & iOS.

## Monorepo
Dart workspace managed with **Melos** (`fvm dart run melos <script>`). Each subdirectory is a separate package. Key packages:

| Package             | Purpose                                                                  |
|---------------------|--------------------------------------------------------------------------|
| `app`               | Flutter UI, routing (auto_route), DI (get_it), state (provider + rxdart) |
| `sfera`             | SFERA XML API integration + local DB cache                               |
| `auth`              | Authentication & state                                                   |
| `mqtt`              | MQTT client                                                              |
| `settings`          | Feature flags / RU settings                                              |
| `formation`         | Train formation & brake data                                             |
| `warnapp`           | Train start/stop detection                                               |
| `preload`           | Offline journey data preloading                                          |
| `logger`            | Log caching & remote rollover                                            |
| `local_regulations` | Local regulation HTML generation                                         |
| `http_x`            | HTTP extension (auth + logging)                                          |
| `connectivity_x`    | Network connectivity                                                     |
| `app_links_x`       | Deep-link handling                                                       |

## Flavors
`dev`, `inte`, `prod` — entry points: `lib/main_dev.dart`, `lib/main_inte.dart`, `lib/main_prod.dart`

## Key Commands
```sh
fvm dart run melos generate # build_runner + flutter gen-l10n (run after model/l10n changes)
fvm dart run melos test # unit tests across all packages
cd app && fvm flutter run --flavor dev -t lib/main_dev.dart
```

## Code Conventions
- **Line length: 120 characters**
- Prefer private methods (`_header()`) over private widget classes (`_Header()`) within the same file
- Naming: `_widget` not `_buildWidget`
- Logging: Use the `logging` package instead of `print`.

## App Architecture
- Apply the Model-View-ViewModel architectural (MVVM) pattern
- Use Repositories as the sources of truth for your application data
- Use services that interact with external APIs, like client servers and databases.
- Data flow: Services → Repositories → ViewModels → Views
- Views: Write reusable, lean widgets. Restrict logic in Views to UI-specific operations (e.g., animations, layout constraints, simple routing). Pass all required data from the ViewModel.
- ViewModels: Manage UI state and handle user interactions. Inject required data providers (Repositories, ViewModels, Streams) into ViewModels via the constructor.

## Unit testing
- Use GIVEN/WHEN/THEN test structure.
- Name tests like `methodName_whenX_thenY`.
- Use `fake_async` for time-based or debounced updates.

## Localization
Three languages: German (default), French, Italian. Key format: `<PREFIX>_<CONTEXT?>_<LABEL>`
- `c_` = common, `p_<page>_` = page-scoped, `w_<widget>_` = widget-scoped
- ARB files in `app/l10n/`. Regenerate with `melos generate`.

## Code Generation
Models use `build_runner`. After editing annotated files run `melos generate`. Generated files (`*.g.dart`, `*.gr.dart`) must not be edited manually.

## AI Agent Skills
Check `.agent/skills` for specific Agent skills.
