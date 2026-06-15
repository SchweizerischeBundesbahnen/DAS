---
name: dart-workspace-component
description: 'Generate a new Dart workspace component in this monorepo. Use when asked to create or refactor a module or component or when larger pure-dart functionality that can be encapsulated in a component'
---

# Create Dart Workspace Component

## When to Use This Skill

Use this skill when you need to:
- Add a new reusable Dart/Flutter package, module, component to the workspace
- Add larger pure-dart functionality that can be encapsulated in a component

## Prerequisites

- Component name in `snake_case` (example: `customer_oriented_departure`)
- Public API name in `PascalCase` (example: `CustomerOrientedDeparture`)
- Decision whether `app` consumes this component directly

## Step-by-Step Workflow

### 1) Scaffold the workspace component

Create the package directory at repository root and include or extend needed parts.
Check existing components if unsure how to structure component.

```text
<component_name>/
  pubspec.yaml
  analysis_options.yaml
  lib/
    component.dart
    src/
        repository/ # exposed repositories
        model/ # exposed domain models
        api/ # if REST api needed
        data/ # if database needed
  test/
```

### 2) Create `pubspec.yaml` for the component

Follow workspace package conventions and add only required dependencies:

```yaml
name: <component_name>
publish_to: 'none'
version: 1.0.0

environment:
  sdk: ^3.12.0

resolution: workspace

dependencies:
  # workspace
  http_x: 1.0.0
  # external packages as needed

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.15.0
  flutter_lints: ^6.0.0
```

### 3) Create `lib/component.dart`

Expose only the component's public API and models and a creation entrypoint:

```dart
import 'package:<component_name>/src/repository/example_repository.dart';
import 'package:<component_name>/src/repository/example_repository_impl.dart';
import 'package:http_x/component.dart';

export 'package:<component_name>/src/repository/example_repository.dart';
export 'package:<component_name>/src/model/example_model.dart';

class <ComponentName>Component {
  const <ComponentName>Component._();

  static ExampleRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return ExampleRepositoryImpl(
      baseUrl: baseUrl,
      client: client,
    );
  }
}
```

### 4) Integrate in other components

Add the package in `<component>/pubspec.yaml` under workspace package dependencies:

```yaml
dependencies:
  <component_name>: 1.0.0
```

If component is used in `app` component and repository is needed over DI: 

1. Add repository or service in relevant GetIt scope (see `app/lib/di/scopes/scopes.dart`):

```dart
void register<ComponentName>Repository() {
  final flavor = DI.get<Flavor>();
  registerSingleton<<ComponentName>Repository>(
    <ComponentName>Component.createRepository(baseUrl: flavor.backendUrl, client: DI.get()),
  );
}
```

2. Call `getIt.register<ComponentName>Repository();` in scope setup before dependent ViewModels are registered.

### 5) Validate and generate

Run the standard workspace checks after scaffolding:

```sh
fvm dart run melos generate
fvm dart run melos test
```

## Implementation Checklist

- [ ] Package folder and naming follow workspace conventions.
- [ ] Public API exported via `lib/component.dart`.
- [ ] component is added to `pubspec.yaml` where needed.
- [ ] DI registration added when repository is exposed to app.
- [ ] Tests added for repository/service or domain model behavior.
