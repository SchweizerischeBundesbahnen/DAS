# End-to-end Testsuite

## DAS-Backend e2e integration-tests

### REST-API tests

1. das_backend [ApiExtractionTest](./../das_backend/src/test/java/ch/sbb/backend/ApiExtractionTest.java) will generate an OpenApi 3 service-contract specification yaml
2. add maven environment variable `DAS_BACKEND_VERSION`
3. [pom](./pom.xml) will generate an ApiClient out of the specification yaml


## Getting-Started

1. Copy [DAS-Backend_SAMPLE.properties](src/main/resources/DAS-Backend_SAMPLE.properties) to `DAS-Backend.properties` and specify concrete values
