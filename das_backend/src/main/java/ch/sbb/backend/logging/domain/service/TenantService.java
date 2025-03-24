package ch.sbb.backend.logging.domain.service;

import ch.sbb.backend.logging.domain.Tenant;

public interface TenantService {

    Tenant getByIssuerUri(String issuerUri);

    Tenant current();
}
