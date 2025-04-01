package ch.sbb.backend.logging;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import ch.sbb.backend.TestcontainersConfiguration;
import ch.sbb.backend.logging.domain.model.Tenant;
import ch.sbb.backend.logging.infrastructure.config.TenantConfig;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

@SpringBootTest
@Import(TestcontainersConfiguration.class)
class TenantConfigTest {

    @Autowired
    private TenantConfig tenantConfig;

    @Test
    void should_load_tenants_from_configuration() {
        List<Tenant> tenants = tenantConfig.getTenants();
        assertNotNull(tenants);
        assertFalse(tenants.isEmpty());
        assertEquals(1, tenants.size());
        assertEquals("test", tenants.get(0).name());
        assertEquals("3409e798-d567-49b1-9bae-f0be66427c54", tenants.get(0).id());
        assertEquals(
            "https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/v2.0",
            tenants.get(0).issuerUri()
        );
        assertEquals(
            "https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/discovery/v2.0/keys",
            tenants.get(0).jwkSetUri()
        );
    }
}
