---
name: dart-rest-api-service
description: 'Creates a REST api service. Use when asked to add or refactor an API service, REST client and HTTP endpoints, or when building new feature packages that communicate with a backend.'
---

# Add REST API Service

## When to Use This Skill

- User asks to add an API service, create a REST client or add HTTP endpoints
- User needs to implement communication with a backend REST API from a Dart/Flutter package
- User wants to add a new feature package that includes an API layer

## Prerequisites

- The target package must depend on `http_x` (provides `Client`, `Response`, `HttpException`)
- Add `json_annotation` and `json_serializable` to `pubspec.yaml` for request body serialization
- Run `dart run build_runner build` after creating `*.g.dart` files

## Directory Structure

Create the following files inside `lib/src/api/` of your feature package:

```
lib/src/api/
├── <feature>_api_service.dart           # Abstract interface
├── <feature>_api_service_impl.dart      # Concrete implementation
└── <action>/
    ├── <action>_request.dart            # Request class + Response class
    └── <action>_request_body.dart       # JSON-serializable body (if needed)
```

## Step-by-Step Workflow

### 1. Define the Abstract Service Interface

File: `lib/src/api/<feature>_api_service.dart`

Use the template `templates/feature_api_service.dart`.

### 2. Implement the Concrete Service

File: `lib/src/api/<feature>_api_service_impl.dart`

Use the template `templates/feature_api_service_impl.dart`.

### 3. Create a Request Class (with body)

File: `lib/src/api/<action>/<action>_request.dart`

Use the template `templates/action_request.dart`.

### 4. Create a Request Body (JSON-serializable)

File: `lib/src/api/<action>/<action>_request_body.dart`

Use the template `templates/action_request_body.dart`.

Then generate the `*.g.dart` file:

```sh
dart run build_runner build --delete-conflicting-outputs
```

### 5. Create a Simple Request Class (no body, path params only)

File: `lib/src/api/<action>/<action>_request.dart`

Use the template `templates/action_request_no_body.dart`.

## Key Patterns

- **`Client`** comes from `package:http_x/component.dart` (re-exports `package:http/http.dart`)
- **`HttpException.fromResponse(response)`** is thrown on non-2xx status codes
- **`Response`** is the standard `http` package response
- **Request classes are callable** via `call(...)` — they are used as `await service.subscribe(...)`
- **Request body** uses `@JsonSerializable()` and a `part '*.g.dart'` directive
- **`toJsonString()`** is provided on the body class for convenient serialization

## Troubleshooting

| Issue                             | Solution                                                               |
|-----------------------------------|------------------------------------------------------------------------|
| `*.g.dart` file missing           | Run `dart run build_runner build --delete-conflicting-outputs`         |
| `Client` not found                | Add `http_x` to `pubspec.yaml` dependencies                            |
| `HttpException` not found         | Import `package:http_x/component.dart`                                 |
| JSON serialization not generating | Ensure `json_annotation` and `json_serializable` are in `pubspec.yaml` |
| `part` directive error            | Ensure the `part` file name matches exactly `<filename>.g.dart`        |

## References

- Templates: `templates/` folder in this skill
- http_x package: `http_x/lib/component.dart`

