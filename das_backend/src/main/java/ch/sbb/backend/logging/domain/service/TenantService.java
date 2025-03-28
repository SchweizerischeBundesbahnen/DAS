package ch.sbb.backend.logging.domain.service;

import ch.sbb.backend.logging.domain.model.Tenant;

public interface TenantService {

    Tenant getByIssuerUri(String issuerUri);

    Tenant current();
}
