package ch.sbb.backend.domain.tenancy

import ch.sbb.backend.infrastructure.configuration.TenantConfig
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.springframework.stereotype.Service

/**
 * Service providing tenant information based on the iss claim of the JWT token.
 */
@Service
class ConfigTenantService(private val tenantConfig: TenantConfig) : TenantService {

    private val logger: Logger = LogManager.getLogger(ConfigTenantService::class.java)

    override fun getByIssuerUri(issuerUri: String): TenantConfig.Tenant {
        val tenant: TenantConfig.Tenant =
            tenantConfig.tenants.stream().filter { t -> issuerUri == t.issuerUri }
                .findAny()
                .orElseThrow { IllegalArgumentException("unknown tenant") }

        logger.debug("got tenant with name=${tenant.name}")

        return tenant
    }

    override fun getById(tenantId: TenantId): TenantConfig.Tenant {
        return tenantConfig.tenants.stream().filter { t -> tenantId == TenantId(t.id!!) }
            .findAny()
            .orElseThrow { IllegalArgumentException("unknown tenant") }
    }

}

