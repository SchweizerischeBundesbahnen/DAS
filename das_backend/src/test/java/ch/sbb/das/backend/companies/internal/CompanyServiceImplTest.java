package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.companies.Tenant;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(classes = ApplicationConfiguration.class)
@ActiveProfiles("test")
class CompanyServiceImplTest {

    @Autowired
    private ApplicationConfiguration applicationConfiguration;

    private CompanyServiceImpl underTest;

    @BeforeEach
    void setUp() {
        underTest = new CompanyServiceImpl(applicationConfiguration);
    }

    /**
     * @see ApplicationConfigurationTest
     */
    @Test
    void getTenantByIssuerUri() {
        Tenant tenant = underTest.getTenantByIssuerUri("https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0");
        assertThat(tenant).isNotNull();
        assertThat(tenant.name()).isEqualTo("sbb");

        tenant = underTest.getTenantByIssuerUri("https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/v2.0");
        assertThat(tenant).isNotNull();
        assertThat(tenant.name()).isEqualTo("unknown-tenant");
    }

    @Test
    void getTenantByIssuerUri_badUri() {
        assertThatThrownBy(() -> underTest.getTenantByIssuerUri("https://bad.issuer"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");
    }
}
