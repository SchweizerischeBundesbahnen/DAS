package ch.sbb.das.backend.common.config;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.RequestIdFilter;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.DateTimeSchema;
import io.swagger.v3.oas.models.media.NumberSchema;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.media.StringSchema;
import io.swagger.v3.oas.models.parameters.HeaderParameter;
import io.swagger.v3.oas.models.parameters.Parameter;
import io.swagger.v3.oas.models.security.OAuthFlow;
import io.swagger.v3.oas.models.security.OAuthFlows;
import io.swagger.v3.oas.models.security.Scopes;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityScheme.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;
import org.springdoc.core.customizers.GlobalOperationCustomizer;
import org.springdoc.core.utils.SpringDocUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tools.jackson.databind.JsonNode;

@Configuration
public class OpenApiConfig {

    public static final String OAUTH_2 = "oauth2";

    static {
        SpringDocUtils.getConfig()
            .replaceWithSchema(JsonNode.class,
                new Schema<>().description("Any valid JSON value."));
    }

    @Value("${info.app.version}") private String applicationVersion;

    @Value("${auth.audience.service-name}") private String serviceName;

    @Value("${spring.security.oauth2.authorizationUrl}") private String authorizationUrl;

    @Bean
    public OpenAPI openApiConfiguration() {
        final String scope = getScope();
        return new OpenAPI().components(
            new Components().addSecuritySchemes(OAUTH_2, addOAuthSecurityScheme(scope))
                .addSchemas("ErrorResponse",
                    new Schema<Map<String, Object>>()
                        .addProperty("timestamp", new DateTimeSchema())
                        .addProperty("status", new NumberSchema())
                        .addProperty("error", new StringSchema())
                        .addProperty("path", new StringSchema()))

        ).security(List.of(new SecurityRequirement().addList(OAUTH_2, List.of(scope)))).info(apiInfo());
    }

    /**
     * Documents the optional {@link ApiParametersDefault#HEADER_REQUEST_ID} on every operation, handled centrally by {@link RequestIdFilter}.
     * <p>
     * Always the first parameter: generated clients (see das_e2e_testsuite sortParamsByRequiredFlag=false) derive their argument order from it.
     */
    @Bean
    public GlobalOperationCustomizer requestIdHeaderCustomizer() {
        return (operation, handlerMethod) -> {
            final List<Parameter> parameters = new ArrayList<>();
            parameters.add(new HeaderParameter()
                .name(ApiParametersDefault.HEADER_REQUEST_ID)
                .description(ApiDocumentation.HEADER_REQUEST_ID_DESCRIPTION)
                .required(false)
                .schema(new StringSchema()));
            if (operation.getParameters() != null) {
                parameters.addAll(operation.getParameters());
            }
            return operation.parameters(parameters);
        };
    }

    private String getScope() {
        return "api://" + serviceName + "/.default";
    }

    private Info apiInfo() {
        final String versionInformation = StringUtils.isNotBlank(applicationVersion) ? " v" + applicationVersion : "";
        return new Info().title("DAS Backend API").version(versionInformation).contact(new Contact().name("DAS").url("https://github.com/SchweizerischeBundesbahnen/DAS"));
    }

    private SecurityScheme addOAuthSecurityScheme(String scope) {
        final Scopes scopes = new Scopes().addString(scope, "Global access");

        final OAuthFlows flowAuthorizationCode = new OAuthFlows()
            .authorizationCode(new OAuthFlow().authorizationUrl(authorizationUrl + "/authorize").tokenUrl(authorizationUrl + "/token").scopes(scopes))
            .clientCredentials(new OAuthFlow().tokenUrl(authorizationUrl + "/token").scopes(scopes));

        return new SecurityScheme().name(OAUTH_2).type(Type.OAUTH2).flows(flowAuthorizationCode);
    }
}
