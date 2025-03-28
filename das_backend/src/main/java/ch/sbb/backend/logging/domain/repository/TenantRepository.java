package ch.sbb.backend.logging.domain.repository;

import ch.sbb.backend.logging.domain.model.Tenant;

public interface TenantRepository {

    Tenant current();

    Tenant getByIssuerUri(String issuerUri);
}
