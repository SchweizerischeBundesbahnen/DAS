# app – Agent Guide

## Purpose

The Flutter UI shell. Composes every other workspace package into the driver-facing app.

## Ownership

* owns routing following standard `auto_route` structure
* owns scoped `get_it` dependency injection
* owns ViewModels provided via `provider` and models exposed using `rxDart` streams
* owns localization following standard `i18n` setup

If changing ViewModels or DI scoping refer to `docs/ARCHITECTURE.md` for the MVVM pattern and DI scoping.

## Flavors

Three flavors — `dev`, `inte`, `prod` — with entry points `lib/main_dev.dart`, `lib/main_inte.dart`,
`lib/main_prod.dart`.

If needed: Read `lib/flavor.dart` for the actual per-flavor values rather than assuming them.

```sh
cd app && fvm flutter run --flavor dev -t lib/main_dev.dart
```
