package ch.sbb.das.backend.restapi.configuration;

import ch.sbb.das.backend.restapi.iam.SSOAuthorizationTokenService;
import ch.sbb.das.backend.restapi.iam.SSOTokenUtils;
import ch.sbb.das.backend.restapi.iam.ssoutils.RestRequester;
import ch.sbb.das.backend.restapi.iam.ssoutils.WebClientConfiguration;
import ch.sbb.das.backend.restapi.iam.ssoutils.WebClientRestRequester;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URISyntaxException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration for IAM SSO like preferred AzureAD.
 */
@Slf4j
@Configuration
public class SSOTokenServiceConfiguration {

    private final SSOConfiguration ssoConfiguration;

    public SSOTokenServiceConfiguration(SSOConfiguration ssoConfiguration) {
        this.ssoConfiguration = ssoConfiguration;
    }

    /**
     * @return token-service for most Test scenarios
     * @throws URISyntaxException
     */
    @Bean(name = "defaultClientId")
    public SSOAuthorizationTokenService ssoAuthorizationTokenService() throws URISyntaxException {
        try {
            log.info("SSO: going to create AzureAD instance..");
            return SSOTokenUtils
                .createAuthorizationTokenService(ssoConfiguration.getSsoTokenEndpoint(), ssoConfiguration.getScope(), ssoConfiguration.getClientId(), ssoConfiguration.getClientSecret(),
                    ssoRestRequester());
        } catch (URISyntaxException e) {
            log.error("Invalid sso.token-endpoint={}", ssoConfiguration.getSsoTokenEndpoint());
            throw e;
        }
    }

    private RestRequester ssoRestRequester() {
        return new WebClientRestRequester(
            new ObjectMapper(),
            createSsoWebClientConfiguration().createWebClient());
    }

    private WebClientConfiguration createSsoWebClientConfiguration() {
        return WebClientConfiguration.builder()
            .timeoutConnect(10 * 1000)
            .timeoutRead(10 * 1000)
            .build();
    }
}
