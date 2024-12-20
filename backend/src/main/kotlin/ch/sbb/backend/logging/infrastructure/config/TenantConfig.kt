package ch.sbb.backend.logging.infrastructure.config

import ch.sbb.backend.logging.domain.Tenant
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties
@ConfigurationProperties("auth")
class TenantConfig {
    var tenants: List<Tenant> = ArrayList()
}
