package ch.sbb.backend.infrastructure.configuration

import com.nimbusds.jose.proc.SecurityContext
import com.nimbusds.jwt.proc.DefaultJWTProcessor
import com.nimbusds.jwt.proc.JWTClaimsSetAwareJWSKeySelector
import com.nimbusds.jwt.proc.JWTProcessor
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.invoke
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2TokenValidator
import org.springframework.security.oauth2.jwt.*
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter
import org.springframework.security.web.SecurityFilterChain


@Configuration
@EnableWebSecurity
class WebSecurityConfig {

    companion object {
        private const val ROLES_KEY: String = "roles"
        private const val ROLE_PREFIX: String = "ROLE_"
    }

    @Value("\${auth.audience.service-name}")
    private val serviceName: String? = null

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http {
            authorizeRequests {
                authorize("/swagger-ui/**", permitAll)
                authorize("/v3/api-docs/**", permitAll)
                authorize("/actuator/health", permitAll)
                authorize("/api/**", hasRole("admin"))
                authorize("/**", denyAll)
            }
            csrf { disable() }
            oauth2ResourceServer {
                jwt {
                    jwtAuthenticationConverter = jwtAuthenticationConverter()
                }
            }
        }
        return http.build()
    }

    @Bean
    fun jwtProcessor(keySelector: JWTClaimsSetAwareJWSKeySelector<SecurityContext>): JWTProcessor<SecurityContext> {
        val jwtProcessor = DefaultJWTProcessor<SecurityContext>()
        jwtProcessor.jwtClaimsSetAwareJWSKeySelector = keySelector
        return jwtProcessor
    }

    @Bean
    fun jwtDecoder(jwtProcessor: JWTProcessor<SecurityContext>?): JwtDecoder {
        val decoder = NimbusJwtDecoder(jwtProcessor)
        val audienceValidator: OAuth2TokenValidator<Jwt> = JwtClaimValidator(
            JwtClaimNames.AUD
        ) { aud: List<String?> -> aud.contains(serviceName) }
        val validator: OAuth2TokenValidator<Jwt> =
            DelegatingOAuth2TokenValidator(JwtValidators.createDefault(), audienceValidator)
        decoder.setJwtValidator(validator)
        return decoder
    }

    @Bean
    fun jwtAuthenticationConverter(): JwtAuthenticationConverter {
        // We define a custom role converter to extract the roles from the Entra ID's JWT token and convert them to granted authorities.
        // This allows us to do role-based access control on our endpoints.
        val roleConverter = JwtGrantedAuthoritiesConverter()
        roleConverter.setAuthoritiesClaimName(ROLES_KEY)
        roleConverter.setAuthorityPrefix(ROLE_PREFIX)

        val jwtAuthenticationConverter = JwtAuthenticationConverter()
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(roleConverter)

        return jwtAuthenticationConverter
    }
}
