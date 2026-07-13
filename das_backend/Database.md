# Database handling

This page explains how das_backend manages its PostgreSQL database: how to run one locally, how
schema changes are made, and the SQL conventions every migration must follow.

New here? Start with [README.md](README.md) — it walks through starting a local DB (`podman compose up`,
see [compose.yaml](compose.yaml)) and running `DASBackendApplication`. This page picks up from there
and covers everything database-specific.

## Flyway

Every schema change **must** go through [Flyway](https://flywaydb.org/) — manual changes to the
database are not allowed. Flyway keeps the schema versioned alongside the service, so it's always
obvious which application version introduced which change.

To make a change:
1. Add a SQL script (DDL, and DML if you're changing data too) under
   [`src/main/resources/db/migration`](src/main/resources/db/migration).
2. Name it following Flyway's
   [versioned migration](https://documentation.red-gate.com/fd/versioned-migrations-273973333.html)
   convention, e.g. `V1.15__add_train_category.sql`. See also the
   [Flyway naming strategy](https://flywaydb.org/documentation/concepts/migrations#naming-1).

⚠️ **Once a migration has run, don't touch it.** Flyway checksums each script the first time it
executes and records it in `flyway_schema_history`. Editing an already-applied script afterwards
does not update that checksum and will break future deployments. If you need to fix something,
write a new migration instead. [Repairs or rollbacks](https://flywaydb.org/documentation/tutorials/undoFlyway)
of an applied breaking change are possible but tricky — avoid needing them in the first place.

## SQL conventions

Write SQL in a broad dialect to avert vendor lock in.

### SQL DDL

* All DDL keywords are UPPERCASE; table and column names are lowercase `snake_case` (JPA maps these
  to the CamelCase entity fields for you).
* Every table has a numeric `id` column as its PRIMARY KEY.
* **Every constraint is named explicitly**, prefixed with the table name. Relying on
  auto-generated names makes them painful to find and `DROP` later.
* Optional: Timestamp columns use `TIMESTAMP WITH TIME ZONE` and store values in UTC, named with an `_at`
  suffix (e.g. `created_at`, `updated_at`). This avoids ambiguity once data crosses time zones —
  relevant for a system that talks to Swiss railway infrastructure over SFERA.
* A table only ever belongs to the [module](ARCHITECTURE.md) that owns it. Per the
  **No Shared Database Storage** rule, a module must never query or join another module's tables —
  cross-module reads go through that module's public Java interface instead.

A minimal example putting the naming and constraint rules together:

```sql
CREATE TABLE IF NOT EXISTS train_category
(
    id         INTEGER                  NOT NULL,
    code       TEXT                     NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE IF EXISTS train_category
    ADD CONSTRAINT train_category_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS train_category
    ADD CONSTRAINT train_category_code_unique UNIQUE (code);

CREATE INDEX IF NOT EXISTS train_category_created_at_idx
    ON train_category (created_at);
```

Constraint naming patterns used above, generalized:
* **PRIMARY KEY**: `ALTER TABLE IF EXISTS <table> ADD CONSTRAINT <table>_id_pk PRIMARY KEY(id);`
* **FOREIGN KEY**: `ALTER TABLE IF EXISTS <table> ADD CONSTRAINT <table>_<property>_fk FOREIGN KEY (<property>) REFERENCES <referenced_table>(id);`
* **UNIQUE**: `ALTER TABLE <table> ADD CONSTRAINT <table>_<property_or_name>_unique UNIQUE (<property>, ..);`
* **INDEX**: `CREATE INDEX IF NOT EXISTS <table>_<property_or_name>_idx ON <table> (<property>, ..);`

Don't store sentinel/dummy values (e.g. `"UNKNOWN"` as a `company.name`) — make the column
`NULL`-able instead. Readers can then decide how to handle the absence of a value, rather than
having a magic string baked into the data.

## DB roles

Follow the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege):
* Don't develop against an Admin or Write-enabled user.
* Use dedicated READ-ONLY users for DAS-Client requests.

## DB tools

* **IntelliJ Ultimate** — the "Database" panel gives you a SQL console, table browser, and a
  graphical schema view.
* [pgAdmin](https://www.pgadmin.org/) — full PostgreSQL management (GRANTs, etc.).
* [SQL Developer](https://www.oracle.com/database/sqldeveloper/) — Oracle's tool, works with
  Postgres via a plugin; user-friendly and pre-installed by SBB EAIO.

## Mapping DB to Java

Entities are mapped with [Spring Data JPA](https://spring.io/projects/spring-data-jpa).
