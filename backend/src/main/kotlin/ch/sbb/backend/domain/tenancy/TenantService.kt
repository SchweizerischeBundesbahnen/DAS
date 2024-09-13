package ch.sbb.backend.domain.tenancy

import ch.sbb.backend.infrastructure.configuration.TenantConfig

interface TenantService {
    fun getByIssuerUri(issuerUri: String): TenantConfig.Tenant
    fun getById(tenantId: TenantId): TenantConfig.Tenant
}
