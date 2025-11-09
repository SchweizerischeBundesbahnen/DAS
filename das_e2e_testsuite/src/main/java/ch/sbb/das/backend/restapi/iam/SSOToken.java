package ch.sbb.das.backend.restapi.iam;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.UUID;
import lombok.Data;

/**
 * IAM SSO-Token data-structure. Such tokens are given by AzureAD or RedHat SSO services.
 * <p>
 * Relevant for SSO-authentication by APIM.
 * <p>
 * Response of {@link SSOExchangeConstants#SSO_HOST_TOKEN_PATH}
 */
@JsonIgnoreProperties("ext_expires_in")
@Data
public class SSOToken {

    /**
     * JWT header.body.signature to authenticate against APIM.
     */
    @JsonProperty("access_token")
    private String accessToken;

    @JsonProperty("expires_in")
    private long expiresInMilliseconds;

    @JsonProperty("refresh_expires_in")
    private long refreshExpiresInMilliseconds;

    @JsonProperty("refresh_token")
    private String refreshToken;

    /**
     * For e.g. "bearer"
     *
     * @see SSOExchangeConstants#SSO_BEARER_TOKEN_PREFIX
     */
    @JsonProperty("token_type")
    private String tokenType;

    @JsonProperty("not-before-policy")
    private long notBeforePolicy;

    @JsonProperty("session_state")
    private UUID sessionId;

    @JsonProperty("scope")
    private String scope;
}
