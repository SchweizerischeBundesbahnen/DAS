# App Architecture

## MVVM (`app` package)

- Data flow: Services → Repositories → ViewModels → Views.
- Views: lean, reusable widgets. Keep logic UI-only (animations, layout constraints, simple routing); take all data from
  the ViewModel instead of computing it in the widget.
- ViewModels: own UI state and user-interaction handling. Dependencies (repositories, other ViewModels, streams) are
  constructor-injected, never looked up inside the ViewModel.
- DI is scope-based via `get_it`; scopes live in `app/lib/di/scopes/` and are entered/exited as the user's session
  progresses (e.g. `authenticated` on login, `journey` once a train journey is loaded).

To scaffold a new ViewModel, use the `flutter-view-model` skill.

## Component pattern (feature packages)

Relevant skills for changing or adding new components (also called feature packages):

* In general, refer to the `dart-workspace-component` skill
* to add a REST API service inside one, use `dart-rest-api-service`
