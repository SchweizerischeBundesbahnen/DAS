package ch.sbb.backend.tenancy.infrastructure;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import ch.sbb.backend.tenancy.domain.repository.TenantRepository;
import ch.sbb.backend.tenancy.infrastructure.config.TenantConfig;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class ConfigTenantRepository implements TenantRepository {

    private final TenantConfig tenantConfig;

    public ConfigTenantRepository(TenantConfig tenantConfig) {
        this.tenantConfig = tenantConfig;
    }

    @Override
    public Tenant getByIssuerUri(@NonNull String issuerUri) {
        Tenant tenant = tenantConfig.getTenants().stream()
            .filter(t -> issuerUri.equals(t.issuerUri()))
            .findAny()
            .orElseThrow(() -> new IllegalArgumentException("unknown tenant"));
        log.debug("got Tenant::name={}", tenant.name());
        return tenant;
    }
}


