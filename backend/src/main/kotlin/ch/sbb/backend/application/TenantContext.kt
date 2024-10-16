package ch.sbb.backend.application

import ch.sbb.backend.domain.tenancy.TenantId
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt

class TenantContext private constructor() {
    val tenantId: TenantId

    init {
        val jwt = SecurityContextHolder.getContext().authentication.principal as Jwt
        val tenantIdString = jwt.claims["tid"] as String
        tenantId = TenantId(tenantIdString)
    }

    companion object {
        fun current(): TenantContext {
            return TenantContext()
        }
    }
}
