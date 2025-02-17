package ch.sbb.backend.logging.infrastructure

import ch.sbb.backend.logging.application.TenantContext
import ch.sbb.backend.logging.domain.Tenant
import ch.sbb.backend.logging.domain.TenantId
import ch.sbb.backend.logging.domain.repository.TenantRepository
import ch.sbb.backend.logging.infrastructure.config.TenantConfig
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.springframework.stereotype.Component

@Component
class ConfigTenantRepository(private val tenantConfig: TenantConfig) : TenantRepository {

    private val logger: Logger = LogManager.getLogger(ConfigTenantRepository::class.java)

    override fun current(): Tenant {
        return getById(TenantContext.current().tenantId)
    }

    override fun getByIssuerUri(issuerUri: String): Tenant {
        val tenant: Tenant =
            tenantConfig.tenants.stream().filter { t -> issuerUri == t.issuerUri }
                .findAny()
                .orElseThrow { IllegalArgumentException("unknown tenant") }

        logger.debug("got tenant with name=${tenant.name}")

        return tenant
    }

    private fun getById(tenantId: TenantId): Tenant {
        return tenantConfig.tenants.stream().filter { t -> tenantId == TenantId(t.id) }
            .findAny()
            .orElseThrow { IllegalArgumentException("unknown tenant") }
    }

}

