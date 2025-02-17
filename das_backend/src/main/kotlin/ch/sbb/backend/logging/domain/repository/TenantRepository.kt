package ch.sbb.backend.logging.domain.repository

import ch.sbb.backend.logging.domain.Tenant

interface TenantRepository {
    fun current(): Tenant
    fun getByIssuerUri(issuerUri: String): Tenant
}
