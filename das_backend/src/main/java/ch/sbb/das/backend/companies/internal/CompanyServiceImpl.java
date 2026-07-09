package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.companies.Tenant;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.NonNull;
import org.springframework.stereotype.Component;

@Component
public class CompanyServiceImpl implements CompanyService {

    private final Map<CompanyShortName, CompanyCode> ricsCodeMap;
    private final ApplicationConfiguration applicationConfiguration;

    public CompanyServiceImpl(ApplicationConfiguration applicationConfiguration) {
        this.applicationConfiguration = applicationConfiguration;
        this.ricsCodeMap = applicationConfiguration.getCompanyCodes().entrySet().stream()
            .collect(Collectors.toMap(
                entry -> new CompanyShortName(entry.getKey()),
                entry -> new CompanyCode(entry.getValue()),
                (a, b) -> a
            ));
    }

    @Override
    public Optional<CompanyCode> findCompanyCodeByCompanyShortName(CompanyShortName shortName) {
        return Optional.ofNullable(ricsCodeMap.get(shortName));
    }

    @Override
    public Map<CompanyCode, CompanyShortName> getAllCompanies() {
        return ricsCodeMap.entrySet().stream()
            .collect(Collectors.toMap(Map.Entry::getValue, Map.Entry::getKey, (a, b) -> a));
    }

    @Override
    public Tenant getTenantByIssuerUri(@NonNull String issuerUri) {
        return applicationConfiguration.getTenants().stream()
            .filter(t -> issuerUri.equals(t.issuerUri()))
            .findAny()
            .orElseThrow(() -> new IllegalArgumentException("unknown tenant"));
    }

    @Override
    public boolean isAdminTenant(Tenant tenant) {
        return Objects.equals(applicationConfiguration.getAdminTenantId(), tenant.getId());
    }
}
