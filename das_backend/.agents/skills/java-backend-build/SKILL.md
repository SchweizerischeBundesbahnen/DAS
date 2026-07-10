---
name: java-backend-build
description: 'Build, test, and run the DAS Backend (Spring Boot / Maven). Use when compiling, running tests, packaging, or starting the backend locally. Always pass -DskipSchemaDownload to skip the Kafka Schema Registry download that requires VPN/network access.'
---

# Java Backend Build, Test & Run

## When to Use This Skill

- Compiling or building the backend
- Running unit or integration tests
- Starting the application locally
- Packaging a JAR for deployment
- Any Maven command executed in `das_backend/`

## Critical: Always Use `-DskipSchemaDownload`

The project uses the Confluent Kafka Schema Registry Maven plugin which downloads schemas from a remote registry. This requires VPN access and will **fail in local/agent environments** without it.

**Always add `-DskipSchemaDownload`** to every `mvn` command. This activates a Maven profile that:
- Skips the Kafka schema registry download
- Uses checked-in schemas from `src/main/resources/schemas` instead

## Commands

All commands are run from the repository root with `-f das_backend/pom.xml`, or from inside `das_backend/`.

### Compile

```sh
mvn compile -f das_backend/pom.xml -DskipSchemaDownload
```

### Compile (including tests)

```sh
mvn test-compile -f das_backend/pom.xml -DskipSchemaDownload
```

### Run All Tests

```sh
mvn test -f das_backend/pom.xml -DskipSchemaDownload
```

### Run a Specific Test Class

```sh
mvn test -f das_backend/pom.xml -DskipSchemaDownload -Dtest="MyTestClass"
```

### Run Tests Matching a Pattern

```sh
mvn test -f das_backend/pom.xml -DskipSchemaDownload -Dtest="*Controller*"
```

### Package (build JAR)

```sh
mvn clean package -f das_backend/pom.xml -DskipSchemaDownload -DskipTests
```

### Run Locally (Spring Boot)

```sh
mvn spring-boot:run -f das_backend/pom.xml -DskipSchemaDownload
```

Requires environment variables and DB setup — see `README.md` and `Database.md`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Cannot invoke "String.replaceFirst..." because "baseUrl" is null` | You forgot `-DskipSchemaDownload` |
| `kafka-schema-registry-maven-plugin` failure | Add `-DskipSchemaDownload` |
| Tests fail with DB connection errors | Integration tests need a running PostgreSQL — see `Database.md` |
| `jsonschema2pojo` not generating | Ensure `src/main/resources/schemas` contains the checked-in schemas |

## Notes

- Java version: 25 (see `pom.xml` for exact configuration)
- The project uses Lombok — ensure annotation processing is enabled
- Code generation plugins (JAXB, jsonschema2pojo) run during the `generate-sources` phase
- Do not run Maven with `-pl das_backend` from the root — there is no parent POM reactor; use `-f das_backend/pom.xml` instead
