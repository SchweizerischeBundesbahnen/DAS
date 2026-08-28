---
name: java-backend-architecture
description: 'Modular architecture rules for the DAS Backend. Use when creating endpoints, services, modules, cross-module communication, or making structural changes to the backend codebase.'
---

# Java Backend Architecture

## When to Use This Skill

- Creating or modifying REST endpoints or controllers
- Adding new services or modules
- Working with cross-module communication or data access
- Making structural changes to package layout

## Reference

Read `das_backend/ARCHITECTURE.md` — it defines the Structured Modular Monolith rules:

- **Strict encapsulation**: only root-package classes are public API, `internal/` subpackages are private
- **No shared DB storage**: never inject another module's repository or JPA entity, no cross-module SQL JOINs
- **Async event-driven communication**: use `@ApplicationModuleListener` (not `@EventListener`)
- **API segregation**: admin (unversioned CRUD) vs driver (versioned, mobile-optimized)
