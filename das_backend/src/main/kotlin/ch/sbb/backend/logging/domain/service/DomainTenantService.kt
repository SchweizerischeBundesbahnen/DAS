package ch.sbb.backend.logging.domain.service

import ch.sbb.backend.logging.domain.Tenant
import ch.sbb.backend.logging.domain.repository.TenantRepository

class DomainTenantService(private val tenantRepository: TenantRepository) : TenantService {
    override fun getByIssuerUri(issuerUri: String): Tenant {
        return tenantRepository.getByIssuerUri(issuerUri)
    }

    override fun current(): Tenant {
        return tenantRepository.current()
    }
}
