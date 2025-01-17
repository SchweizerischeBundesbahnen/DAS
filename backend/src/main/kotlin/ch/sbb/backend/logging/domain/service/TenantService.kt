package ch.sbb.backend.logging.domain.service

import ch.sbb.backend.logging.domain.Tenant

interface TenantService {
    fun getByIssuerUri(issuerUri: String): Tenant
    fun current(): Tenant
}
