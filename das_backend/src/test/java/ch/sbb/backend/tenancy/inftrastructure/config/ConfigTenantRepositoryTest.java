package ch.sbb.backend.tenancy.inftrastructure.config;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import ch.sbb.backend.tenancy.infrastructure.ConfigTenantRepository;
import ch.sbb.backend.tenancy.infrastructure.config.TenantConfig;
import com.nimbusds.jose.KeySourceException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(classes = TenantConfig.class)
@ActiveProfiles("test")
class ConfigTenantRepositoryTest {

    @Autowired
    private TenantConfig tenantConfig;

    private ConfigTenantRepository tenantRepository;

    @BeforeEach
    void setUp() {
        tenantRepository = new ConfigTenantRepository(tenantConfig);
    }

    /**
     * @see TenantConfigTest
     */
    @Test
    void getByIssuerUri() {
        Tenant tenant = tenantRepository.getByIssuerUri("https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/v2.0");
        assertThat(tenant).isNotNull();
        assertThat(tenant.name()).isEqualTo("test");
    }

    @Test
    void getByIssuerUri_badUri() {
        assertThatThrownBy(() -> tenantRepository.getByIssuerUri("https://bad.issuer"))
            .isInstanceOf(KeySourceException.class)
            .hasMessageContaining("unknown tenant");
    }
}
