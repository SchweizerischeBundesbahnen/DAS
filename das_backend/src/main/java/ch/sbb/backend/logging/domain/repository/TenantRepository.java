package ch.sbb.backend.logging.domain.repository;

import ch.sbb.backend.logging.domain.Tenant;

public interface TenantRepository {

    Tenant current();

    Tenant getByIssuerUri(String issuerUri);
}
