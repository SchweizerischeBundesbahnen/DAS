package ch.sbb.backend.logging.infrastructure;

import ch.sbb.backend.logging.application.TenantContext;
import ch.sbb.backend.logging.domain.Tenant;
import ch.sbb.backend.logging.domain.TenantId;
import ch.sbb.backend.logging.domain.repository.TenantRepository;
import ch.sbb.backend.logging.infrastructure.config.TenantConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class ConfigTenantRepository implements TenantRepository {

    private static final Logger log = LoggerFactory.getLogger(ConfigTenantRepository.class);
    
    private final TenantConfig tenantConfig;

    public ConfigTenantRepository(TenantConfig tenantConfig) {
        this.tenantConfig = tenantConfig;
    }

    @Override
    public Tenant current() {
        return getById(TenantContext.current().getTenantId());
    }

    @Override
    public Tenant getByIssuerUri(String issuerUri) {
        Tenant tenant = tenantConfig.getTenants().stream().filter(t -> issuerUri.equals(t.issuerUri())).findAny().orElseThrow(() -> new IllegalArgumentException("unknown tenant"));
        log.debug("got tenant with name=${tenant.name}");
        return tenant;
    }

    private Tenant getById(TenantId tenantId) {
        return tenantConfig.getTenants().stream().filter(t -> tenantId == new TenantId(t.id()))
            .findAny()
            .orElseThrow(() -> new IllegalArgumentException("unknown tenant"));
    }
}


