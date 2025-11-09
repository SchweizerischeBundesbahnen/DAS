package ch.sbb.das.backend.restapi.iam;

import ch.sbb.das.backend.restapi.iam.ssoutils.RequesterExchangeException;
import ch.sbb.das.backend.restapi.iam.ssoutils.RequesterMappingException;
import ch.sbb.das.backend.restapi.iam.ssoutils.RestRequester;
import ch.sbb.das.backend.restapi.iam.ssoutils.WebClientConfiguration;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.springframework.http.HttpHeaders;
import org.springframework.util.CollectionUtils;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.client.ClientRequest;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * SBB IAM offers an SSO-Token Service: AzureAD
 * <p>
 * This service considers explicitely tokens with a {@link SSOExchangeConstants#SSO_BEARER_TOKEN_PREFIX} which can be validated by APIM.
 */
@Slf4j
public class SSOAuthorizationTokenService implements AuthorizationTokenService {

    private static final String FORM_CLIENT_ID = "client_id";
    private static final String FORM_CLIENT_SECRET = "client_secret";
    private static final String FORM_SCOPE = "scope";

    private final RestRequester requester;
    private final URI tokenEndpoint;
    private final MultiValueMap<String, String> formData;
    private ClientRequest request;

    /**
     * Configure SSO Token-Service which may differ per environment (TEST/INT/PROD) and Token-Provider.
     *
     * @param tokenEndpoint SSO endpoint (authorization-URL)
     * @param scope SSO specific scope
     * @param clientId SSO specific Client-ID
     * @param clientSecret SSO specific Client-Secret for clientId
     * @param restRequester configured for SSO host (like WebClient)
     */
    SSOAuthorizationTokenService(@NonNull String tokenEndpoint, @NonNull String scope, @NonNull String clientId, @NonNull String clientSecret, @NonNull RestRequester restRequester)
        throws URISyntaxException {
        try {
            this.tokenEndpoint = new URI(tokenEndpoint);
        } catch (URISyntaxException ex) {
            log.error("Misconfigured SSO Token Endpoint: {}->{}", tokenEndpoint, ex.getMessage());
            throw ex;
        }
        this.formData = createFormData(scope, clientId, clientSecret);
        this.requester = restRequester;
    }

    /**
     * For consumers {@link HttpHeaders#AUTHORIZATION} must be set by Consumer at request time.
     * <p>
     * However {@link HttpHeaders#AUTHORIZATION} token expected by various other APIM validated backends (like Beacons, CAPRE, Atlas, ..) will be created by an interceptor configured by
     * {@link WebClientConfiguration} and an AuthorizationFilter.
     *
     * @param request to be issued with a valid SSO JWT (Bearer) token
     * @return valid SSO JWT token prefixed by {@link SSOExchangeConstants#SSO_BEARER_TOKEN_PREFIX}
     */
    @Override
    @NonNull
    public Flux<String> token(@NotNull ClientRequest request) {
        // try to reuse already given token from previous authentication
        final List<String> authorizationHeaders = request.headers().get(HttpHeaders.AUTHORIZATION);
        final String clientId = formData.getFirst(FORM_CLIENT_ID);
        if (!CollectionUtils.isEmpty(authorizationHeaders)) {
            final String jwtToken = SSOTokenUtils.findFirstBearerPrefexidToken(authorizationHeaders.iterator());
            if (jwtToken != null) {
                if (SSOTokenUtils.isBearerTokenExpired(jwtToken)) {
                    log.info("expired previously issued token, going to renew for ClientId={}", clientId);
                } else {
                    log.debug("reuse previously issued token ClientId={}", clientId);
                    return Flux.just(jwtToken);
                }
            }
        }

        // create new SSO JWT Bearer token
        try {
            SSOToken token = requester.requestAndMap(SSOToken.class, tokenEndpoint, formData);
            if (token.getAccessToken().startsWith(SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX)) {
                return Flux.just(token.getAccessToken());
            } else {
                // we manipulate token if other API like WeatherService expects Prefix
                log.debug("{} prefixed for SSO-Token", SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX);
                return Flux.just(SSOExchangeConstants.SSO_BEARER_TOKEN_SPACED + token.getAccessToken());
            }
        } catch (RequesterExchangeException exchangeException) {
            log.error("Token issuing failed from IAM SSO with clientId {} for {} ", clientId, request.url(), exchangeException);
        } catch (RequesterMappingException mappingException) {
            log.error("SSOToken mapping failed with clientId {} for {} ", clientId, request.url(), mappingException);
        }
        return Flux.empty();
    }

    @Override
    public @NotNull Mono<String> renewToken(@NonNull ClientRequest request) {
        this.request = request;
        log.debug("renew token");
        return token(request).next();
    }

    /**
     * @param scope
     * @param clientId
     * @param clientSecret
     * @return values for SSO issuer login
     */
    private MultiValueMap<String, String> createFormData(String scope, String clientId, String clientSecret) {
        final MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
        formData.add(SSOExchangeConstants.GRANT_TYPE, SSOExchangeConstants.CLIENT_CREDENTIALS);
        formData.add(FORM_CLIENT_ID, StringUtils.trim(clientId));
        formData.add(FORM_CLIENT_SECRET, StringUtils.trim(clientSecret));
        if (StringUtils.isNotBlank(scope)) {
            formData.add(FORM_SCOPE, StringUtils.trim(scope));
        }
        return formData;
    }
}
