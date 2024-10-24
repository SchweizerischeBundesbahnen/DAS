package ch.sbb.sferamock.exchange;

import ch.sbb.sferamock.exchange.TenantConfig.Tenant;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

/**
 * Service providing tenant information based on the iss claim of the JWT token.
 */
@Service
public class TenantService {

    private static final Logger log = LogManager.getLogger(TenantService.class);

    private final TenantConfig tenantConfig;

    public TenantService(TenantConfig tenantConfig) {
        this.tenantConfig = tenantConfig;
    }

    public Tenant getByIssuerUri(String issuerUri) {
        Tenant tenant = tenantConfig.getTenants().stream().filter(t ->
                issuerUri.equals(t.getIssuerUri())
            ).findAny()
            .orElseThrow(() -> new IllegalArgumentException("unknown tenant"));

        log.info(String.format("Got tenant '%s' with issuer URI '%s'", tenant.getName(), tenant.getIssuerUri()));

        return tenant;
    }
}
