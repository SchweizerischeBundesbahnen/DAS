# End-to-end Testsuite

## DAS-Backend e2e integration-tests

Precondition:

*

das_backend [ApiExtractionTest](./../das_backend/src/test/java/ch/sbb/backend/ApiExtractionTest.java)
generates an OpenApi 3
service-contract [api-specification.yaml](./../das_backend/src/main/resources/api/api-specification.yaml)

### REST-API tests

1. Add `Maven-Settings -> Runner` -> `Environment variables` **DAS_BACKEND_VERSION** to
   the [released versions of 'backend'](https://github.com/SchweizerischeBundesbahnen/DAS/releases)
2. [pom](./pom.xml) will generate an ApiClient out of the service-contract yaml (or adapt
   _inputSpec_ temporarily for a service-contract SNAPSHOT-version)
3. upgrade [CI version](../.github/workflows/ci-e2e_testsuite.yml) for latest released to be tested
   automatically


## Getting-Started

1. Copy [DAS-Backend_SAMPLE.properties](src/main/resources/DAS-Backend_SAMPLE.properties) to `DAS-Backend.properties` and specify concrete values
