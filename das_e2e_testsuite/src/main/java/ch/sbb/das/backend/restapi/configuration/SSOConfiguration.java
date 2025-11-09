package ch.sbb.das.backend.restapi.configuration;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

/**
 * IAM Access configuration for DAS-Backend via APIM.
 * <p>
 * When you want to use AzureAd specify the azure-scope "sso.azure.scope" env.
 */
@Getter
@Configuration
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend_SAMPLE.properties")
// override sample with local settings where needed
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend.properties", ignoreResourceNotFound = true)
public class SSOConfiguration {

    /**
     * APIM name for an environment
     */
    @Value("${sso.token-endpoint}")
    private String ssoTokenEndpoint;
    @Value("${sso.scope}")
    private String scope;
    @Value("${sso.client-id}")
    private String clientId;
    @Value("${sso.client-secret}")
    private String clientSecret;

    public SSOConfiguration() {

    }
}
