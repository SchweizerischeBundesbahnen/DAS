package ch.sbb.das.backend.companies;

import java.util.Map;
import java.util.Optional;
import lombok.NonNull;

public interface CompanyService {

    Tenant getTenantByIssuerUri(@NonNull String issuerUri);

    Optional<CompanyCode> findCompanyCodeByCompanyShortName(CompanyShortName shortName);

    Map<CompanyCode, CompanyShortName> getAllCompanies();

    boolean isAdminTenant(Tenant tenant);
}
