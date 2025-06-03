package ch.sbb.backend.common;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.DateTimeSchema;
import io.swagger.v3.oas.models.media.NumberSchema;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.media.StringSchema;
import io.swagger.v3.oas.models.security.OAuthFlow;
import io.swagger.v3.oas.models.security.OAuthFlows;
import io.swagger.v3.oas.models.security.Scopes;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityScheme.Type;
import java.util.List;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    public static final String OAUTH_2 = "oauth2";

    @Value("${info.app.version}") private String applicationVersion;

    @Value("${auth.audience.service-name}") private String serviceName;

    @Value("${spring.security.oauth2.authorizationUrl}") private String authorizationUrl;

    @Bean
    public OpenAPI openApiConfiguration() {
        return new OpenAPI().components(
            new Components().addSecuritySchemes(OAUTH_2, addOAuthSecurityScheme())
                .addSchemas("ErrorResponse",
                    new Schema<Map<String, Object>>()
                        .addProperty("timestamp", new DateTimeSchema())
                        .addProperty("status", new NumberSchema())
                        .addProperty("error", new StringSchema())
                        .addProperty("path", new StringSchema()))

        ).security(List.of(new SecurityRequirement().addList(OAUTH_2))).info(apiInfo());
    }

    private Info apiInfo() {
        final String versionInformation = StringUtils.isNotBlank(applicationVersion) ? " v" + applicationVersion : "";
        return new Info().title("DAS Backend API").version(versionInformation).contact(new Contact().name("DAS").url("https://github.com/SchweizerischeBundesbahnen/DAS"));
    }

    private SecurityScheme addOAuthSecurityScheme() {
        final Scopes scopes = new Scopes().addString("api://" + serviceName + "/.default", "Global access");

        final OAuthFlows flowAuthorizationCode = new OAuthFlows().authorizationCode(
            new OAuthFlow().authorizationUrl(authorizationUrl + "/authorize").tokenUrl(authorizationUrl + "/token").scopes(scopes));

        return new SecurityScheme().name(OAUTH_2).type(Type.OAUTH2).flows(flowAuthorizationCode);
    }
}
