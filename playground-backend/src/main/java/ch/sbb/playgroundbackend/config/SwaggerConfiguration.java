package ch.sbb.playgroundbackend.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.OAuthFlow;
import io.swagger.v3.oas.models.security.OAuthFlows;
import io.swagger.v3.oas.models.security.Scopes;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Collections;

@Configuration
public class SwaggerConfiguration {

    private static final String OAUTH_2 = "oauth2";

    @Value("${info.app.version}")
    private String applicationVersion;

    @Value("${springdoc.swagger-ui.oauth.clientId}")
    private String clientId;

    @Value("${spring.security.oauth2.authorizationUrl}")
    private String authorizationUrl;

    @Bean
    public OpenAPI gleisspiegelOpenAPIConfiguration() {
        return new OpenAPI()
            .components(new Components().addSecuritySchemes(OAUTH_2, addOAuthSecurityScheme()))
            .security(Collections.singletonList(new SecurityRequirement().addList(OAUTH_2)))
            .info(apiInfo());
    }

    private Info apiInfo() {
        final String versionInformation = StringUtils.isNotBlank(applicationVersion) ? " v " + applicationVersion : "";
        return new Info()
            .title("Playground Backend" + versionInformation)
            .contact(new Contact()
                .name("Team Zug")
                .url("https://github.com/SchweizerischeBundesbahnen/DAS"));
    }

    private SecurityScheme addOAuthSecurityScheme() {
        final Scopes scopes = new Scopes().addString(clientId + "/.default", "Global access");

        final OAuthFlows flowAuthorizationCode = new OAuthFlows().authorizationCode(new OAuthFlow()
            .authorizationUrl(authorizationUrl + "/authorize")
            .tokenUrl(authorizationUrl + "/token")
            .scopes(scopes));

        return new SecurityScheme().name(OAUTH_2).type(SecurityScheme.Type.OAUTH2).flows(flowAuthorizationCode);
    }

}
