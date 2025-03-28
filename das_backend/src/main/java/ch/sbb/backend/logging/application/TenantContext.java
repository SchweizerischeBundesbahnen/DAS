package ch.sbb.backend.logging.application;

import ch.sbb.backend.logging.domain.model.TenantId;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

public class TenantContext {

    private final TenantId tenantId;

    private TenantContext() {
        Jwt jwt = (Jwt) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String tenantIdString = (String) jwt.getClaims().get("tid");
        tenantId = new TenantId(tenantIdString);
    }

    public static TenantContext current() {
        return new TenantContext();
    }

    public TenantId getTenantId() {
        return tenantId;
    }
}

