package ch.sbb.backend.domain.tenancy

import ch.sbb.backend.infrastructure.configuration.Tenant

interface TenantService {
    fun getByIssuerUri(issuerUri: String): Tenant
    fun getById(tenantId: TenantId): Tenant
}
