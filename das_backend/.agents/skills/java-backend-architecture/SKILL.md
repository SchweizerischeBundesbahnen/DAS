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

- **Strict encapsulation**: only root-package classes are public API, `internal/` subpackages are
  private
- **No shared DB storage**: never inject another module's repository or JPA entity, no cross-module
  SQL JOINs
- **Cross-module communication**: default is a synchronous call through another module's public root
  interface; use `@ApplicationModuleListener` (not `@EventListener`) only where async decoupling is
  needed (not used yet)
- **API segregation**: admin (unversioned CRUD) vs driver (versioned, mobile-optimized)
