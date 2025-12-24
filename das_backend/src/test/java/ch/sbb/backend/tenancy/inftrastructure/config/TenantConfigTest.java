package ch.sbb.backend.tenancy.inftrastructure.config;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import ch.sbb.backend.tenancy.infrastructure.config.TenantConfig;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(classes = TenantConfig.class)
@ActiveProfiles("test")
class TenantConfigTest {

    @Autowired
    private TenantConfig tenantConfig;

    @Test
    void should_load_tenants_from_configuration() {
        List<Tenant> tenants = tenantConfig.getTenants();
        assertThat(tenants).isNotNull()
            .isNotEmpty()
            .hasSize(2);

        Tenant tenant = tenants.getFirst();
        assertThat(tenant.name()).isEqualTo("sbb");
        assertThat(tenant.issuerUri()).isEqualTo("https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0");
        assertThat(tenant.jwkSetUri()).isEqualTo("https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/discovery/v2.0/keys");
        assertThat(tenant.getId()).isEqualTo("2cda5d11-f0ac-46b3-967d-af1b2e1bd01a");

        tenant = tenants.get(1);
        assertThat(tenant.name()).isEqualTo("unknown-tenant");
        assertThat(tenant.issuerUri()).isEqualTo("https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/v2.0");
        assertThat(tenant.jwkSetUri()).isEqualTo("https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/discovery/v2.0/keys");
        assertThat(tenant.getId()).isEqualTo("3409e798-d567-49b1-9bae-f0be66427c54");
    }
}
