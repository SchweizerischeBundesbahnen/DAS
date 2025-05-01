package ch.sbb.backend.logging.inftrastructure.config;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.logging.domain.model.Tenant;
import ch.sbb.backend.logging.infrastructure.config.TenantConfig;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

@SpringBootTest
@Import(TestContainerConfiguration.class)
class TenantConfigTest {

    @Autowired
    private TenantConfig tenantConfig;

    @Test
    void should_load_tenants_from_configuration() {
        List<Tenant> tenants = tenantConfig.getTenants();
        assertThat(tenants).isNotNull()
            .isNotEmpty()
            .hasSize(1);
        Tenant tenant = tenants.getFirst();
        assertThat(tenant.name()).isEqualTo("test");
        assertThat(tenant.id()).isEqualTo("3409e798-d567-49b1-9bae-f0be66427c54");
        assertThat(tenant.issuerUri()).isEqualTo("https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/v2.0");
        assertThat(tenant.jwkSetUri()).isEqualTo("https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/discovery/v2.0/keys");
    }
}
