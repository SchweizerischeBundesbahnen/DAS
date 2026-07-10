# DAS E2E Testsuite - Agent Guide

## Scope
Instructions for AI/code agents working in `das_e2e_testsuite/`.

- Stack: Java, Maven, generated API client tests
- Purpose: backend contract and integration/e2e validation
- Primary source of truth: local code + `README.md` + `pom.xml`

## Before editing
1. Read `README.md`
2. Check `pom.xml` for client generation/test plugins
3. Identify dependency on backend API specification
4. Confirm required environment/config inputs are documented

## Build and test
Run from `das_e2e_testsuite/`.

```sh
mvn clean test
```

## Testsuite-specific rules
- Keep tests aligned with the backend OpenAPI contract.
- Do not hardcode environment-specific endpoints or credentials.
- If API contract assumptions change, update tests and note required backend version/config.
- Prefer deterministic assertions and stable fixtures over timing-dependent checks.
- Keep the suite focused on integration/e2e behavior, not unit-level internals.

## Validation checklist
- Tests run with current intended backend version/config
- Contract-generated client code (if regenerated) is consistent with updated specification
- README/setup notes are updated when required inputs change

