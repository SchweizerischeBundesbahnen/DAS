package ch.sbb.backend.tenancy.domain.repository;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import lombok.NonNull;

public interface TenantRepository {

    Tenant getByIssuerUri(@NonNull String issuerUri);
}
