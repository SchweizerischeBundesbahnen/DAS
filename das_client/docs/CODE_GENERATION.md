# Code Generation

- Models annotated with `@JsonSerializable()` and drift tables use `build_runner`.
- ARB localization files use `flutter gen-l10n`.
- After editing any annotated model or ARB file, run:

```sh
fvm dart run melos generate
```

This runs `build_runner build --delete-conflicting-outputs` in every package that depends on `build_runner`
(`orderDependents`, so downstream packages regenerate after their dependencies), then `flutter gen-l10n` in every
package with an `l10n/` directory (currently only `app`).

- Generated files (`*.g.dart`, `*.gr.dart`, and everything under `app/lib/i18n/gen`) are build output — never edit
  them by hand. Change the annotated source or ARB file and re-run `melos generate` instead.
