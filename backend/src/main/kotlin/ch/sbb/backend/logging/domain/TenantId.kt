package ch.sbb.backend.logging.domain

import java.util.*

@JvmInline
value class TenantId(private val tenantId: String) {

    init {
        require(tenantId.isNotBlank())
        requireNotNull(UUID.fromString(tenantId))
    }
}
