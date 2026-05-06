package ch.sbb.das.backend.tenancy.infrastructure;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyShortName;
import ch.sbb.das.backend.tenancy.infrastructure.config.ApplicationConfiguration;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@org.springframework.modulith.NamedInterface("tenancy")
@Component
public class CompanyCodeRepository {

    private final Map<CompanyShortName, CompanyCode> ricsCodeMap;

    public CompanyCodeRepository(ApplicationConfiguration applicationConfiguration) {
        this.ricsCodeMap = applicationConfiguration.getCompanyCodes().entrySet().stream()
            .collect(Collectors.toMap(
                entry -> CompanyShortName.of(entry.getKey()),
                entry -> CompanyCode.of(entry.getValue()),
                (a, b) -> a
            ));
    }

    public Optional<CompanyCode> findCompanyCode(CompanyShortName shortName) {
        return Optional.ofNullable(ricsCodeMap.get(shortName));
    }

    public Map<CompanyCode, CompanyShortName> getAll() {
        return ricsCodeMap.entrySet().stream()
            .collect(Collectors.toMap(Map.Entry::getValue, Map.Entry::getKey, (a, b) -> a));
    }
}
