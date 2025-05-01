# Handling the database
See [compose.yaml](compose.yaml) to startup a DB-instance on local docker container.

## Flyway
[naming-strategy of flyway](https://flywaydb.org/documentation/concepts/migrations#naming-1)  
Version the database with the current version of the service (easy to recognize in which version the migration was injected).

To make database model changes **`Flyway` MUST be used** as a migration tool (no manual changes!):
* Add **SQL DDL** (and/or SQL DML if data changes are involved too) scripts to [resources/db/migration](src/main/resources/db/migration)
* See [versioned migrations](https://documentation.red-gate.com/fd/versioned-migrations-273973333.html)

IMPORTANT:
* first execution deploys the DB-changes and writes flyway_schema_history::checksum !! Further changes will not update the checksum!
* Once the flyway changes are made to DB, **repair or * [rollbacks](https://flywaydb.org/documentation/tutorials/undoFlyway) might be tricky** in case of breaking changes!

## SQL conventions
Remarks:
* Write SQL statements in a broader dialect (there are plenty of specialisations since SQL 98 for each DB provider and product migration is always foreseeable):
    * PostgreSQL (currently used by this project)
    * H2 (might come in handy for in-memory Unit-Tests)

### SQL DDL
* all SQL DDL code is written as UPPERCASE
* model code (table- and property-names) is written as lowercase (use '_' instead of CamelCase, mapping to Entity classes is made by JPA)
* each table has a technical, numeric `id` as PRIMARY KEY
* **CONSTRAINT names must be always specified explicitely** (DB products auto-create their own generic names and might turn into a mess to DROP them later):
    * to reduce naming conflicts and missunderstandings start all contraint-names prefixed with table-name
    * **PRIMARY KEY**: ```ALTER TABLE IF EXISTS <table> ADD CONSTRAINT <table>_id_pk PRIMARY KEY(id);```
    * derived **FOREIGN KEYs**: ```ALTER TABLE IF EXISTS <table> ADD CONSTRAINT <table>_<property>_fk FOREIGN KEY (<property>) REFERENCES <table primary>(id);```
    * **INDEX**:
        * ```ALTER TABLE <table> ADD CONSTRAINT <table>_<property OR speaking name>_unique UNIQUE (<property>, ..);```
        * ```CREATE INDEX IF NOT EXISTS <table>_<property OR speaking name>_idx ON <table> (<property>, ..);```

Do not save dummy values (like "UNKNOWN") for e.g. as company::name -> make it NULLable instead (reader might change to default value if wanted).

## DB roles
[Wikipedia - Principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege) Make sure production rights are as restricted as possible, for e.g.:
* do not develop with Admin or Write enabled users
* declare READ-ONLY users for DAS-Client requests

## DB Tools
Some recommendations:
* __IntelliJ ultimate__ edition provides in "Database" panel SQL-Query Console, table opening, graphical schema
* [pgAdmin](https://www.pgadmin.org/) for PostgreSQL allows complete DB-mgmt such as GRANTs, etc.
* [SqlDeveloper](https://www.oracle.com/database/sqldeveloper/) from Oracle works on Postgres with a dedicated plug-in and is user-friendly (installed by SBB EAIO).

## Mapping DB to Java
See:
* [Spring Data JPA](https://spring.io/projects/spring-data-jpa)