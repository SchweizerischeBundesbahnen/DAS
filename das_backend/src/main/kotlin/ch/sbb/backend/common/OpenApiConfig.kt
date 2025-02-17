package ch.sbb.backend.common

import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Contact
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.media.DateTimeSchema
import io.swagger.v3.oas.models.media.NumberSchema
import io.swagger.v3.oas.models.media.Schema
import io.swagger.v3.oas.models.media.StringSchema
import io.swagger.v3.oas.models.security.*
import org.apache.commons.lang3.StringUtils
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {

    companion object {
        private const val OAUTH_2: String = "oauth2"
    }

    @Value("\${info.app.version}")
    private val applicationVersion: String? = null

    @Value("\${springdoc.swagger-ui.oauth.clientId}")
    private val clientId: String? = null

    @Value("\${spring.security.oauth2.authorizationUrl}")
    private val authorizationUrl: String? = null

    @Bean
    fun openAPIConfiguration(): OpenAPI {
        return OpenAPI()
            .components(
                Components()
                    .addSecuritySchemes(OAUTH_2, addOAuthSecurityScheme())
                    .addSchemas(
                        "ErrorResponse",
                        Schema<Map<String, Any>>()
                            .addProperty("timestamp", DateTimeSchema())
                            .addProperty("status", NumberSchema())
                            .addProperty("error", StringSchema())
                            .addProperty("path", StringSchema())
                    )
            )
            .security(listOf(SecurityRequirement().addList(OAUTH_2)))
            .info(apiInfo())
    }

    private fun apiInfo(): Info {
        val versionInformation =
            if (StringUtils.isNotBlank(applicationVersion)) " v$applicationVersion" else ""
        return Info()
            .title("DAS Backend API")
            .version(versionInformation)
            .contact(
                Contact()
                    .name("DAS")
                    .url("https://github.com/SchweizerischeBundesbahnen/DAS")
            )
    }

    private fun addOAuthSecurityScheme(): SecurityScheme {
        val scopes = Scopes().addString(
            "$clientId/.default", "Global access"
        )

        val flowAuthorizationCode = OAuthFlows().authorizationCode(
            OAuthFlow()
                .authorizationUrl("$authorizationUrl/authorize")
                .tokenUrl("$authorizationUrl/token")
                .scopes(scopes)
        )

        return SecurityScheme().name(OAUTH_2).type(SecurityScheme.Type.OAUTH2)
            .flows(flowAuthorizationCode)
    }
}
