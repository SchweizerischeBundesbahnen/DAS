package ch.sbb.das.backend.restapi.iam;

import static org.springframework.http.HttpMethod.GET;

import ch.sbb.das.backend.restapi.helper.DeveloperException;
import java.io.IOException;
import java.net.URI;
import java.util.Collections;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.ClientRequest;
import reactor.core.publisher.Flux;

/**
 * Test utility to get a fresh Bearer-Token (for e.g. used by APIM).
 */
@Slf4j
@Component
public class SSOTokenInterceptor implements ClientHttpRequestInterceptor {

    private final SSOAuthorizationTokenService ssoAuthorizationTokenService;

    @Autowired
    public SSOTokenInterceptor(SSOAuthorizationTokenService ssoAuthorizationTokenService) {
        this.ssoAuthorizationTokenService = ssoAuthorizationTokenService;
    }

    @Override
    public @NotNull ClientHttpResponse intercept(HttpRequest httpRequest, byte @NotNull [] bytes, ClientHttpRequestExecution clientHttpRequestExecution) throws IOException {
        httpRequest.getHeaders().put(HttpHeaders.AUTHORIZATION, Collections.singletonList(getApimSsoToken(null)));
        return clientHttpRequestExecution.execute(httpRequest, bytes);
    }

    /**
     * @param jwt null for a fresh one
     * @return bearer token
     * @see SSOTokenUtils
     */
    public String getApimSsoToken(String jwt) {
        // Strange URI: due to the implementation of the AuthorizationTokenService (WebClient) this workaround/placeholder is needed. The URI will and must never be used. Just a placeholder.
        ClientRequest clientRequest = ClientRequest.create(GET, URI.create("https://mussNotBeNull.url/")).header(HttpHeaders.AUTHORIZATION, jwt).build();
        return requestAsyncToken(ssoAuthorizationTokenService.token(clientRequest));
    }

    private String requestAsyncToken(@NonNull Flux<String> tokenFlux) {
        final String tokenSSO = tokenFlux.blockFirst();
        if (StringUtils.isBlank(tokenSSO)) {
            throw new DeveloperException("SSO Flux<token> is null -> check SSOConfiguration");
        }
        log.debug("new SSO Token: {}", tokenSSO);
        return tokenSSO;
    }
}
