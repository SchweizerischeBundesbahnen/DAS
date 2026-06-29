---
name: flutter-view-model
description: 'Create reactive Flutter view models. Use when asked to build or refactor Flutter ViewModel classes that listen to streams, map domain models to UI state and expose read-only state.'
---

# Create Flutter View Models

## When to Use This Skill

Use this skill when generating or refactoring Flutter view models that:
- Listen to one or more upstream streams (for example settings or repository streams)
- Expose derived state via `Stream<T>` and synchronous getters for current values
- Encapsulate user actions and update logic in dedicated methods

## Prerequisites

- `rxdart` is available for `BehaviorSubject` and stream operators
- `logging` is available for diagnostics (`Logger`)

## View Model Template

```dart
import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('GenericViewModel');

class GenericViewModel {
  GenericViewModel({required this._repository}) {
    _init();
  }

  final SferaRepository _repository;

  final BehaviorSubject<String> _rxState = BehaviorSubject<String>();

  StreamSubscription<SferaRemoteRepositoryState>? _stateSubscription;

  Stream<String> get state => _rxState.distinct();

  String get stateValue => _rxState.value;

  void onUserAction() {
    _log.info('User tapped on ui element');
    _rxState.add('User tapped');
  }

  Future<void> dispose() async {
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    await _rxState.close();
  }

  void _init() {
    _stateSubscription = _repository.stateStream.listen((state) {
      if (state == .disconnected) {
        _rxState.add('Disconnected');
      }
    });
  }
}
```

### Complex State Model
If simple data classes like `bool`, `String` etc. are not enough, use sealed classes

- Use sealed unions to model state variants (e.g., `Valid`, `Expired`, `ExpirySoon`)
- Include all necessary data as immutable properties in each state variant

```dart
// view_model_model.dart
sealed class AppExpirationModel {
  final String currentAppVersion;
  
  AppExpirationModel({required this.currentAppVersion});
}

class Valid extends AppExpirationModel {
  Valid({required String currentAppVersion}) : super(currentAppVersion: currentAppVersion);
}

class Expired extends AppExpirationModel {
  Expired({required String currentAppVersion}) : super(currentAppVersion: currentAppVersion);
}

class ExpirySoon extends AppExpirationModel {
  ExpirySoon({
    required this.expiryDate,
    required String currentAppVersion,
  }) : super(currentAppVersion: currentAppVersion);
  
  final DateTime expiryDate;
}
```

## Implementation Checklist

1. Inject all dependencies via constructor.
2. Keep mapping logic deterministic and side-effect free where possible.
3. Expose only read-only streams from the view model API.
4. Use `distinct()` to avoid redundant widget rebuilds.
5. Cancel all subscriptions and close all owned subjects in `dispose()`.
6. Keep UI-only concerns in Widgets; keep state and interaction logic in the ViewModel.
