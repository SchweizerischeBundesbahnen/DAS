package ch.sbb.das.backend.tenancy.domain.repository;

import ch.sbb.das.backend.tenancy.domain.model.Tenant;
import lombok.NonNull;

public interface TenantRepository {

    Tenant getByIssuerUri(@NonNull String issuerUri);

    boolean isAdminTenant(Tenant tenant);
}
