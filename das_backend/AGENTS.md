# DAS Backend - Agent Guide

## Scope
Instructions for AI/code agents working in `das_backend/`.

- Stack: Java 25, Spring Boot, Maven
- Primary source of truth: local code + `README.md` + `Database.md`
- This file overrides root guidance for backend-specific tasks

## Before editing
1. Read `README.md`
2. Read `ARCHITECTURE.md` — defines module boundaries, encapsulation rules, and API segregation
3. Read `Database.md`
4. Check `pom.xml` for plugin/dependency implications
5. Inspect related tests under `src/test/`

## Build, test, run

⚠️ **Always pass `-DskipSchemaDownload`** to every Maven command. See `java-backend-build` skill for full details.

```sh
mvn compile -DskipSchemaDownload
mvn clean test -DskipSchemaDownload
mvn spring-boot:run -DskipSchemaDownload
```

Notes:
- Local run requires environment variables and DB setup referenced in `README.md` and `Database.md`.
- Do not hardcode secrets; keep credentials external.

## Backend-specific rules
- Keep API contracts backward compatible unless explicitly requested otherwise.
- If a change affects OpenAPI/output contracts, verify generated contract artifacts and dependent tests.
- Keep schema/code generation flows intact (JSON schema, JAXB, and Maven plugins defined in `pom.xml`).
- Avoid changing unrelated module boundaries or package structure without clear need.
- **Tests are mandatory** — see `java-backend-testing` skill for strategy and patterns.

## Validation checklist
- Run relevant unit/integration tests in `src/test/`
- Validate formatting/linting conventions used by the existing codebase
- Confirm no secrets/certificates are added to git

