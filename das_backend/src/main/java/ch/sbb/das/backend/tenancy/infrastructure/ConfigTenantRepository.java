package ch.sbb.das.backend.tenancy.infrastructure;

import ch.sbb.das.backend.tenancy.domain.model.Tenant;
import ch.sbb.das.backend.tenancy.domain.repository.TenantRepository;
import ch.sbb.das.backend.tenancy.infrastructure.config.ApplicationConfiguration;
import java.util.Objects;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class ConfigTenantRepository implements TenantRepository {

    private final ApplicationConfiguration applicationConfiguration;

    public ConfigTenantRepository(ApplicationConfiguration applicationConfiguration) {
        this.applicationConfiguration = applicationConfiguration;
    }

    @Override
    public Tenant getByIssuerUri(@NonNull String issuerUri) {
        Tenant tenant = applicationConfiguration.getTenants().stream()
            .filter(t -> issuerUri.equals(t.issuerUri()))
            .findAny()
            .orElseThrow(() -> new IllegalArgumentException("unknown tenant"));
        log.info("Tenant::name={}", tenant.name());
        return tenant;
    }

    @Override
    public boolean isAdminTenant(Tenant tenant) {
        return Objects.equals(applicationConfiguration.getAdminTenantId(), tenant.getId());
    }
}


