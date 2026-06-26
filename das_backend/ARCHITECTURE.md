# DAS-Backend: Architecture & Modular Guidelines

This repository is designed as a **Structured Modular Monolith** using [Spring Modulith]https://docs.spring.io/spring-modulith/reference/). Every functional domain is completely isolated so that it can be effortlessly extracted into a standalone microservice in the future if required.

## 🛠️ The Core Architectural Rules

1. **Strict Encapsulation**:
    * Any package under `ch.sbb.das.backend.<module>` represents a distinct bounded context. Also called a module.
    * Each module owns its data, API surface, and internal implementation- Modules may choose their internal architecture as long as the core rules above are respected.
    * Only classes placed directly in the **root package** of a module function as its public API (Interfaces and shared DTOs).
    * Everything inside an `internal/` or other subpackage is strictly private. Peer modules are **forbidden** from importing these components.
2. **No Shared Database Storage**:
    * A module must never inject a database repository or JPA entity belonging to another module.
    * Cross-module SQL `JOIN` statements are strictly prohibited. Data lookups across domains must go exclusively through public root Java interfaces.
3. **Asynchronous Event-Driven Communication**:
    * Inter-module workflows execute asynchronously via Spring Application Events.
    * Use **`@ApplicationModuleListener`** instead of standard Spring `@EventListener`. This routes events through an integrated database outbox log table, guaranteeing delivery and fault tolerance.
4. **Strict API Segregation**:
    * **Admin (web app)**: Operational, unversioned CRUD endpoints. (e.g. `api/admin/ruindications` for managing RU indications)
    * **Driver (mobile app)**: Mobile optimized, versioned endpoints. (e.g. `api/driver/v1/ruindications` for driver-facing RU indications matching)


## 🗺️ Current Module Blueprint

* `common`: The unique global `OPEN` shared module. It houses cross-cutting components like `ResponseEntityFactory`, `ApiResponse`, security definitions. Keep `common` small — no business rules should live here.


* `companies`
* `locations`
* `appversions`
* `features`
* `indications` — RU indications, templates, holiday handling
* `externallinks`
* `departure`
* `cargo`
* `trainjourneyplan` — timetable to train identifications
* `trainjourneypreloader` — preloader, streaming & IO responsibilities (MQTT, buffering, S3 artifacts)
* `config`
* `personalsettings`
* `driversettings` (API-only) — facade module that implements the mobile-facing driver settings API 
