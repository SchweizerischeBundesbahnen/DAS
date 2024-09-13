package ch.sbb.backend.infrastructure.configuration

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties
@ConfigurationProperties("auth")
class TenantConfig {
    var tenants: List<Tenant> = ArrayList()

    class Tenant {
        var name: String? = null
        var id: String? = null
        var jwkSetUri: String? = null
        var issuerUri: String? = null
        var logDestination: LogDestination? = null

        enum class LogDestination {
            CONSOLE,
            SPLUNK
        }
    }
}
