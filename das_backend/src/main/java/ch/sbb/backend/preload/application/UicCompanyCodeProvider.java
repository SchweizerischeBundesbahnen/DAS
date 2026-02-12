package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.CompanyCode;
import ch.sbb.backend.preload.infrastructure.configuration.ApplicationConfiguration;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
public class UicCompanyCodeProvider {

    private final Map<String, String> uicCodeMap;

    public UicCompanyCodeProvider(ApplicationConfiguration applicationConfiguration) {
        this.uicCodeMap = applicationConfiguration.getUicCompanyCodes();
    }

    public Optional<CompanyCode> getUicCompanyCode(String netsCode) {
        return uicCodeMap.containsKey(netsCode)
            ? Optional.of(CompanyCode.of(uicCodeMap.get(netsCode)))
            : Optional.empty();
    }

}
