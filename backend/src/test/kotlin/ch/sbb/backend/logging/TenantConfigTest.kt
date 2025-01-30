package ch.sbb.backend.logging

import ch.sbb.backend.BaseIT
import ch.sbb.backend.TestContainerConfiguration
import ch.sbb.backend.logging.infrastructure.config.TenantConfig
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Import

@Import(TestContainerConfiguration::class)
class TenantConfigTest: BaseIT() {

    @Autowired
    private lateinit var tenantConfig: TenantConfig

    @Test
    fun `should load tenants from configuration`() {
        val tenants = tenantConfig.tenants
        assertNotNull(tenants)
        assertTrue(tenants.isNotEmpty())
        assertEquals(tenants.size, 1)
        assertEquals(tenants[0].name, "test")
        assertEquals(tenants[0].id, "3409e798-d567-49b1-9bae-f0be66427c54")
        assertEquals(
            tenants[0].issuerUri,
            "https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/v2.0"
        )
        assertEquals(
            tenants[0].jwkSetUri,
            "https://login.microsoftonline.com/3409e798-d567-49b1-9bae-f0be66427c54/discovery/v2.0/keys"
        )
    }
}
