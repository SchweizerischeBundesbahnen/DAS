# DAS Monorepo - Agent Guide

## Purpose and scope

This file is the default instruction set for AI/code agents working in the whole repository.

- Scope: entire monorepo rooted at `DAS/`
- Priority: more specific instructions in subfolders override this file (for example
  `das_client/AGENT.md`)
- Goal: deliver minimal, safe, tested changes aligned with active repository conventions

## Read before editing

For each task, read the closest docs first:

1. module `README.md`
2. module `AGENT.md` when present
3. root `README.md`
4. `CONTRIBUTING.md` and `CODING_STANDARDS.md`

Note: treat `docs/` as potentially outdated for now, unless the task explicitly targets docs.

## Monorepo map

- `das_client/`: Flutter/Dart mobile app workspace (Melos + FVM)
- `das_backend/`: Java Spring Boot backend
- `das_admin_tool/`: Angular admin web app
- `das_playground/`: Angular playground/debug web app
- `sfera_mock/`: Spring Boot mock for SFERA/testing
- `das_e2e_testsuite/`: API e2e/integration tests (Maven)

## Working rules

- Keep changes scoped to the requested module; avoid cross-module refactors unless requested.
- Do not change generated artifacts unless regeneration is explicitly part of the task.
- Prefer fixing root cause over introducing temporary workarounds.
- Keep public APIs and contracts backward compatible unless the task explicitly allows breaking
  changes.
- If assumptions are needed (env vars, secrets, external services), document them clearly.

## Module-level agent files

Build/test/run commands are maintained in module agent files:

- `das_client/AGENT.md`
- `das_backend/AGENT.md`
- `das_admin_tool/AGENT.md`
- `das_e2e_testsuite/AGENT.md`

If a module has no `AGENT.md`, use its local `README.md` and package scripts/build tool defaults.

## Coding and quality standards

- Follow `CODING_STANDARDS.md` at repo root.
- For mobile, also follow `das_client/CODING_STANDARDS.md` and `das_client/AGENT.md`.
- Ensure new features/bug fixes include tests (`CONTRIBUTING.md`).
- Do not edit generated Dart files (`*.g.dart`, `*.gr.dart`) manually.
- Keep formatting/linting consistent with the module toolchain.

## Documentation updates

When behavior or configuration changes, update docs that are actively maintained:

- module `README.md` for run/build/test impact
- release/migration notes when relevant

## Commit and PR conventions

- Use Conventional Commits with issue reference (example: `feat: add xyz (#123)`).
- Keep PRs small and reviewable.
- Include: what changed, why, how validated (tests), and env/config implications.

## Safety notes

- Never commit secrets, certificates, private keys, or real credentials.
- Treat `.env`, API keys, and service endpoints as external inputs.
- Avoid destructive data operations in scripts/tests unless explicitly requested.

