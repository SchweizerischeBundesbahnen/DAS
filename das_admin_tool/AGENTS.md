# DAS Admin Tool - Agent Guide

## Scope
Instructions for AI/code agents working in `das_admin_tool/`.

- Stack: Angular, TypeScript, npm
- Primary source of truth: local code + `README.md` + `package.json` scripts
- This file overrides root guidance for admin-tool-specific tasks

## Before editing
1. Read `README.md`
2. Check scripts and dependencies in `package.json`
3. Inspect lint config (`eslint.config.js`) when changing TS/HTML patterns
4. Inspect unit/e2e tests related to the feature

## Build, lint, run
Run from `das_admin_tool/`.

```sh
npm run lint
npm run build
npm start           # ng serve (dev server)
```

## Testing (mandatory)

Every implementation task **must** include tests. See `angular-testing` skill for patterns and commands.

- **Services/classes with business logic** → unit test (Vitest, `*.spec.ts` co-located)
- **User-facing flows** (pages, dialogs, CRUD) → Playwright e2e test (`e2e/tests/`)
- **Bug fixes** → regression test covering the fixed scenario

```sh
npm run test                # unit tests
npm run e2e                 # Playwright e2e (CI)
npm run e2e:local:headed    # Playwright e2e (local, visible browser)
```

## Admin-tool-specific rules
- Keep changes consistent with existing Angular standalone/component patterns.
- Prefer strong typing; avoid `any` unless justified.
- Keep localization, auth, and API integration behavior backward compatible unless requested.
- Do not commit generated build output (`dist/`).

## Validation checklist
- Run lint + affected tests before finalizing
- Build succeeds for the affected target
- No secrets/tokens are introduced in source or configs

