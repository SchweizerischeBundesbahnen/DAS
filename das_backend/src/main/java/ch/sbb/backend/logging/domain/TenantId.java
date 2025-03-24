package ch.sbb.backend.logging.domain;

import java.util.UUID;

public record TenantId(String tenantId) {

    public TenantId {
        if (tenantId == null || tenantId.isBlank()) {
            throw new IllegalArgumentException("tenantId must not be blank");
        }
        try {
            UUID.fromString(tenantId);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid UUID format", e);
        }
    }
}