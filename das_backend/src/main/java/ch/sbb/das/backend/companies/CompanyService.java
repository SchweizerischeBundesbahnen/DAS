package ch.sbb.das.backend.companies;

import java.util.List;
import java.util.Optional;
import lombok.NonNull;

public interface CompanyService {

    Tenant getTenantByIssuerUri(@NonNull String issuerUri);

    Optional<CompanyCode> findCompanyCodeByShortName(CompanyShortName shortName);

    List<Company> getAllCompanies();

}
