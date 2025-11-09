package ch.sbb.das.backend.restapi.iam;

import ch.sbb.das.backend.restapi.iam.ssoutils.RestRequester;
import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import jakarta.servlet.http.HttpServletRequest;
import java.net.URISyntaxException;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import lombok.Getter;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.ApiStatus.Experimental;
import org.springframework.http.HttpHeaders;

/**
 * JWT token utility (for e.g. SBB IAM SSO Bearer tokens).
 *
 * @see <a href="https://tools.ietf.org/html/rfc7519">JSON Web Token (JWT)</a>
 */
@Slf4j
@Getter
public final class SSOTokenUtils {

    static final int BEARER_SUBSTRING_LENGTH = SSOExchangeConstants.SSO_BEARER_TOKEN_SPACED.length();

    /**
     * Factory method for SSO-Token provider.
     * <p>
     * For better SLA make sure to use Microsoft Azure (IAM RedHat-SSO for fallback)
     *
     * @param tokenEndpoint url of SSO-instance
     * @param clientId registered consumer-id
     * @param clientSecret given secret for clientId
     * @param restRequester WebClient
     * @return clientId specific instance
     * @throws URISyntaxException
     */
    public static SSOAuthorizationTokenService createAuthorizationTokenService(@NonNull String tokenEndpoint, @NonNull String scope, @NonNull String clientId, @NonNull String clientSecret,
        @NonNull RestRequester restRequester) throws URISyntaxException {
        return new SSOAuthorizationTokenService(tokenEndpoint, scope, clientId, clientSecret, restRequester);
    }

    private static Iterator<String> extractAuthorizationHeader(@NonNull HttpServletRequest request) {
        return request.getHeaders(HttpHeaders.AUTHORIZATION).asIterator();
    }

    /**
     * @param request might contain [0..*] {@link HttpHeaders#AUTHORIZATION}
     * @return first Bearer JWT token or null
     */
    public static String findFirstBearerPrefexidToken(@NonNull HttpServletRequest request) {
        return findFirstBearerPrefexidToken(extractAuthorizationHeader(request));
    }

    static String findFirstBearerPrefexidToken(Iterator<String> tokens) {
        while (tokens.hasNext()) {
            final String jwt = tokens.next();
            if (isBearerPrefixedToken(jwt)) {
                log.debug("{} token found", SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX);
                return jwt;
            }
        }
        log.debug("no AUTHORIZATION header with {} prefix", SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX);
        return null;
    }

    /**
     * @param jwtToken any AUTHORIZATION JWT token
     * @return true: APIM SSO relevant token prefixed by "Bearer".
     */
    static boolean isBearerPrefixedToken(String jwtToken) {
        return StringUtils.isNotBlank(jwtToken) && jwtToken.startsWith(SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX);
    }

    /**
     * Does not guarantee validation against APIM (other circumstances like revoke might happen).
     * <p>
     * see AuthorizationFilter::retryIfUnauthorizedAndRenewToken
     *
     * @param jwtToken existing JWT token
     * @return whether timestamp within JWT token is before NOW
     */
    public static boolean isBearerTokenExpired(String jwtToken) {
        final DecodedJWT decodedJWT = decodeJwt(normalizeToken(jwtToken));
        return checkBearerTokenExpired(decodedJWT) != null;
    }

    /**
     * @return {@code null} if token not expired, else an explanation message for consumer.
     */
    public String checkBearerTokenExpired() {
        return checkBearerTokenExpired(jwtDecoded);
    }

    private static String checkBearerTokenExpired(DecodedJWT decodedJWT) {
        if (decodedJWT == null) {
            return "no JWT token found -> assume expired";
        }
        final Date expirationDate = decodedJWT.getExpiresAt();
        if (expirationDate == null) {
            return "JWT token has no expiration-date -> assume expired";
        } else if (expirationDate.before(Calendar.getInstance().getTime())) {
            return "JWT token expired since " + expirationDate;
        } else {
            // does not guarantee the token will validate against APIM (if revoked for e.g.)
            return null;
        }
    }

    /**
     * JWT "header.body.signature"
     *
     * @return extracted "clientId" registered by consumer at developer.sbb.ch
     * @see <a href="https://github.com/auth0/java-jwt/blob/master/README.md">A Java implementation of JSON Web Token (JWT) - RFC 7519</a>
     */
    public String extractClientId() {
        if (jwtDecoded != null) {
            if (isAzureAdToken()) {
                return jwtDecoded.getClaim(SSOExchangeConstants.APIM_AZURE_CLIENTID).asString();
            }
            return jwtDecoded.getClaim(SSOExchangeConstants.CLIENT_ID).asString();
        }
        return null;
    }

    /**
     * JWT "header.body.signature"
     *
     * @return extracted "roles" in Azure-Token
     * @see <a href="https://github.com/auth0/java-jwt/blob/master/README.md">A Java implementation of JSON Web Token (JWT) - RFC 7519</a>
     */
    public Set<String> extractClientRoles() {
        if (jwtDecoded != null) {
            if (isAzureAdToken()) {
                final List<String> roles = jwtDecoded.getClaim(SSOExchangeConstants.APIM_AZURE_CLIENT_ROLES).asList(String.class);
                return (roles == null) ? null : Set.copyOf(roles);
            }
        }
        return null;
    }

    /**
     * @return true when from AzureAd, otherwise false
     */
    public boolean isAzureAdToken() {
        return isAzureAdToken;
    }

    static DecodedJWT decodeJwt(String normalizedToken) {
        try {
            return JWT.decode(normalizedToken);
        } catch (Exception ex) {
            log.error("developer fault extracting JWT", ex);
            return null;
        }
    }

    private static String normalizeToken(String jwt) {
        if (jwt.toLowerCase().contains(SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX.toLowerCase())) {
            return jwt.substring(SSOExchangeConstants.SSO_BEARER_TOKEN_PREFIX.length()).trim();
        }
        return jwt;
    }

    /**
     * Because signatures are always byte arrays, Base64URL-encode the signature and append a period character '.' and it to the concatenated string.
     * <p>
     * DO NOT use this method for critical PROD usage!
     *
     * @param jwt complete token "header.payload.signature"
     * @param startOffset just an offset in case something like "Bearer " is prefixed
     * @return jwt's "header.payload." part (both in base64) without "signature" at end
     */
    @Experimental
    public static String extractHeaderAndPayload(String jwt, int startOffset) {
        return jwt.substring(startOffset, jwt.lastIndexOf('.') + 1);
    }

    private final String rawToken;
    private final String normalizedToken;
    private DecodedJWT jwtDecoded = null;
    private Exception jwtDecodingException = null;
    private final boolean isAzureAdToken;

    public SSOTokenUtils(@NonNull HttpServletRequest request) {
        this(findFirstBearerPrefexidToken(request));
    }

    public SSOTokenUtils(String rawToken) {
        this.rawToken = rawToken;
        if (StringUtils.isNotBlank(rawToken)) {
            this.normalizedToken = normalizeToken(rawToken);
            try {
                this.jwtDecoded = JWT.decode(normalizedToken);
            } catch (Exception ex) {
                log.debug("developer fault extracting JWT", ex); // logged later
                this.jwtDecodingException = ex;
            }
            if (jwtDecoded != null) {
                final String issuer = jwtDecoded.getClaim(SSOExchangeConstants.BEARER_TOKEN_ISSUER).asString();
                isAzureAdToken = issuer.contains(SSOExchangeConstants.BEARER_TOKEN_AZURE_ISSUER);
            } else {
                isAzureAdToken = false;
            }
        } else {
            this.normalizedToken = null;
            isAzureAdToken = false;
        }
    }

    public boolean isEmpty() {
        return normalizedToken == null;
    }
}
