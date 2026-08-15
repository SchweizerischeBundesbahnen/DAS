---
name: java-backend-testing
description: 'Write and run tests for the DAS Backend. Use when implementing features, adding endpoints, creating services, fixing bugs, writing unit tests, integration tests, controller tests, or adding test coverage. Tests are mandatory for every implementation task — not optional.'
---

# Java Backend Testing

## When to Use This Skill

**This skill applies to every implementation task** — not just when explicitly asked to write tests.

- Implementing a new feature or endpoint → write tests alongside
- Fixing a bug → add a regression test
- Refactoring existing code → ensure existing tests pass, add missing coverage
- Explicitly asked to write or add tests

## Running Tests

⚠️ **Always use `-DskipSchemaDownload`** — see `java-backend-build` skill for full build/run details.

```sh
mvn test -f das_backend/pom.xml -DskipSchemaDownload                                          # all tests
mvn test -f das_backend/pom.xml -DskipSchemaDownload -Dtest="MyServiceTest"                   # specific class
mvn test -f das_backend/pom.xml -DskipSchemaDownload -Dtest="*Controller*"                    # pattern
mvn test -f das_backend/pom.xml -DskipSchemaDownload -Dtest="MyServiceTest#method_when_then"  # single method
```

## Testing Strategy

**Always write:**
- **Integration/controller tests** for every API endpoint (MockMvc + `@IntegrationTest`)

**Additionally write:**
- **Unit tests (service tests)** when a service contains business logic (Mockito, no Spring context)
- **Unit tests** for other classes that contain business logic (mappers, validators, utilities)
- **Service integration tests** when there is no controller/API layer (e.g., scheduled jobs, event listeners, internal services without REST exposure) — use `@IntegrationTest` without MockMvc, inject the service directly

In short: controller tests are mandatory, unit tests are added where there is logic worth testing in isolation.

## Test Types & Conventions

### Unit Tests (Mockito)

For service-layer logic. Use `@ExtendWith(MockitoExtension.class)` with `@Mock` and `@InjectMocks`.

```java
@ExtendWith(MockitoExtension.class)
class MyServiceTest {

    @Mock
    private MyRepository myRepository;

    @Mock
    private OtherService otherService;

    @InjectMocks
    private MyService myService;

    @Test
    void myMethod_scenario_expectedResult() {
        // Given
        when(myRepository.findById(1)).thenReturn(Optional.of(entity));

        // When
        var result = myService.myMethod(1);

        // Then
        assertThat(result).isEqualTo(expected);
    }
}
```

**Conventions:**
- Test method naming: `methodName_scenario_expectedResult`
- Use Given/When/Then comments for structure
- Use AssertJ (`assertThat(...)`) for assertions
- Use `ReflectionTestUtils.setField(entity, "field", value)` for entities with private fields

### Integration Tests (Controller / API)

For REST endpoints. Use `@IntegrationTest` (custom composite annotation) which provides:
- `@SpringBootTest` with full context
- `@ActiveProfiles("test")`
- `@AutoConfigureMockMvc`
- Testcontainers for PostgreSQL and Kafka

```java
@IntegrationTest
@Sql({"classpath:createCompaniesAndTenants.sql", "classpath:createMyTestData.sql"})
class MyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getResource_returnsExpectedData() throws Exception {
        mockMvc.perform(get(API_MY_ENDPOINT)
                .param("paramName", "value"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[0].field").value("expected"));
    }
}
```

### Security / Role Testing

Use `@WithMockRole` to test role-based access:

```java
@Test
@WithMockRole(roles = UserRole.DRIVER)
void endpoint_driverRole_isAllowed() throws Exception { ... }

@Test
@WithMockRole(roles = UserRole.OBSERVER)
void endpoint_observerRole_isAllowed() throws Exception { ... }

@Test
@WithMockRole(roles = UserRole.ADMIN)
void endpoint_adminRole_isAllowed() throws Exception { ... }

@Test
void endpoint_unauthenticated_returns401() throws Exception { ... }
```

Available roles (see `UserRole`): `DRIVER`, `OBSERVER`, `ADMIN`, `RU_ADMIN`

The `adminTenant` flag (default `true`) controls which tenant the mock JWT belongs to.

## Test Data (SQL Fixtures)

Place SQL files in `src/test/resources/`. Load with `@Sql` on the test class or method.

```sql
DELETE FROM my_table;

INSERT INTO my_table (id, name, value)
VALUES (nextval('my_table_id_seq'), 'test_name', 'test_value');
```

**Conventions:**
- Start with `DELETE FROM` to ensure clean state
- Use `nextval('..._id_seq')` for auto-increment IDs
- Prefix test fixture files with `create` (e.g., `createMyTestData.sql`)
- Reuse existing fixtures like `createCompaniesAndTenants.sql` when your tests need company data

## Test Checklist

- [ ] Integration/controller test for every API endpoint (MockMvc + `@IntegrationTest`)
- [ ] Unit tests for services/classes with business logic
- [ ] Test all relevant security roles (authorized + unauthorized)
- [ ] Test error cases (400 for bad input, 404 for not found)
- [ ] Test edge cases (empty results, null handling, boundary values)
- [ ] If a new API endpoint was added: add an e2e test in `das_e2e_testsuite` (see below)

## E2E Testsuite (`das_e2e_testsuite/`)

A separate module in the monorepo that tests the backend REST API against a running instance. Uses a **generated OpenAPI client** from the backend's `api-specification.yaml`.

### When to Add E2E Tests

- When a **new API endpoint** is added to the backend
- When existing API contract/behavior changes

### How It Works

1. `das_backend` generates `api-specification.yaml` via `ApiExtractionTest`
2. `das_e2e_testsuite/pom.xml` generates a REST client from that spec
3. Tests run against a deployed backend instance (configured via properties)

### Structure

```
das_e2e_testsuite/src/test/java/.../e2etest/
├── api/                    # API test classes (one per endpoint group)
│   ├── SettingsApiTest.java
│   ├── FormationsApiTest.java
│   └── ...
├── configuration/          # Test profiles and API client setup
│   ├── ApiClientTestProfile.java
│   └── DasBackendApiTest.java
└── helper/                 # Shared utilities (RestAssured, assertions)
    ├── RestAssuredCommand.java
    └── AssertionsResponse.java
```

### Writing an E2E Test

```java
@ApiClientTestProfile
@Slf4j
class MyNewApiTest extends RestAssuredCommand {

    static final String ENDPOINT = "/v1/my-endpoint";

    @Autowired
    DasBackendApi backendApi;

    @Autowired
    DasBackendEndpointConfiguration endpointConfiguration;

    @BeforeEach
    void setUpContext() throws Exception {
        configure(endpointConfiguration);
        TestContextManager testContextManager = new TestContextManager(getClass());
        testContextManager.prepareTestInstance(this);
    }

    @Test
    void myEndpoint_returns200() {
        Response response = createRequestWithHeader("en", getRequestId())
            .param("myParam", "value")
            .when()
            .get(getUrl(ENDPOINT))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.SC_OK);
    }
}
```

### Running E2E Tests

```sh
# Requires DAS-Backend.properties with endpoint + credentials
mvn clean test -f das_e2e_testsuite/pom.xml
```

**Prerequisites:**
- Copy `src/main/resources/DAS-Backend_SAMPLE.properties` → `DAS-Backend.properties` with real values
- Set `DAS_BACKEND_VERSION` environment variable to the target release version
- Backend instance must be running and accessible

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Cannot invoke "String.replaceFirst..."` | Forgot `-DskipSchemaDownload` — see `java-backend-build` skill |
| Testcontainer startup failure | Ensure Docker is running |
| `@Sql` file not found | Path must start with `classpath:` and file goes in `src/test/resources/` |
| Security test unexpectedly passes/fails | Check `@WithMockRole` roles match `WebSecurityConfig` matchers |
| `ReflectionTestUtils` fails | Verify field name matches the entity's private field exactly |
