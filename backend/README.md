# Backend

## Introduction


## Getting-Started
1. Run a Docker Daemon
2. Add environment variables 
   1. either by run configuration
   2. or a .env file
3. Run `BackendApplication`

## Flyway
To make a database change Flyway is used as a migration tool. 
Add SQL script to [resources/db/migration](src/main/resources/db/migration) 
also see [versioned migrations](https://documentation.red-gate.com/fd/versioned-migrations-273973333.html).