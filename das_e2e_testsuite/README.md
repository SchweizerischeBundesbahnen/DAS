# End-to-end Testsuite

## DAS-Backend e2e integration-tests

Precondition:

- In case of testing das_backend with the latest local-host
  changes: [ApiExtractionTest](./../das_backend/src/test/java/ch/sbb/backend/ApiExtractionTest.java)
  generates an OpenApi 3
  service-contract [api-specification.yaml](./../das_backend/src/main/resources/api/api-specification.yaml)

### REST-API tests

1. Add `Maven-Settings -> Runner` -> `Environment variables` **DAS_BACKEND_VERSION** to
   the [released versions of 'das_backend'](https://github.com/SchweizerischeBundesbahnen/DAS/releases)
2. [pom](./pom.xml) will generate an ApiClient out of the service-contract yaml matching
   DAS_BACKEND_VERSION (or adapt _inputSpec_ temporarily for a das_backend service-contract
   SNAPSHOT-version on local host)
3. upgrade [CI version](../.github/workflows/e2e_testsuite_ci.yml) for latest released to be tested
   automatically


## Getting-Started

1. Copy [DAS-Backend_SAMPLE.properties](src/main/resources/DAS-Backend_SAMPLE.properties) to `DAS-Backend.properties` and specify concrete values
