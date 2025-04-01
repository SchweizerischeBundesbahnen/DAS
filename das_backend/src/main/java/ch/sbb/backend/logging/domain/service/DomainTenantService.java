package ch.sbb.backend.logging.domain.service;

import ch.sbb.backend.logging.domain.model.Tenant;
import ch.sbb.backend.logging.domain.repository.TenantRepository;

public class DomainTenantService implements TenantService {

    private final TenantRepository tenantRepository;

    public DomainTenantService(TenantRepository tenantRepository) {
        this.tenantRepository = tenantRepository;
    }

    @Override
    public Tenant getByIssuerUri(String issuerUri) {
        return tenantRepository.getByIssuerUri(issuerUri);
    }

    @Override
    public Tenant current() {
        return tenantRepository.current();
    }
}
