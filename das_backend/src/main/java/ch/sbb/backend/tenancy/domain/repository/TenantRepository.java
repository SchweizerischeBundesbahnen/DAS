package ch.sbb.backend.tenancy.domain.repository;

import ch.sbb.backend.tenancy.domain.model.Tenant;

public interface TenantRepository {

    Tenant getByIssuerUri(String issuerUri);
}
