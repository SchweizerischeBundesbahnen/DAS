package ch.sbb.das.backend.restapi.iam;

import lombok.experimental.UtilityClass;

/**
 * Some constanst for AzureAD and RedHatSSO IAM usage.
 */
@UtilityClass
public final class SSOExchangeConstants {

    /**
     * RedHat-SSO apim.sso-host issued tokens for authorization start with a Bearer-Prefix.
     *
     * @see <a href="https://confluence.sbb.ch/display/AITG/Spring+Boot+Anwendung">Authorziation</a>
     */
    public static final String SSO_BEARER_TOKEN_PREFIX = "Bearer";
    static final String SSO_BEARER_TOKEN_SPACED = SSO_BEARER_TOKEN_PREFIX + " ";
    public static final String BEARER_TOKEN_ISSUER = "iss";

    public static final String BEARER_TOKEN_AZURE_ISSUER = "login.microsoftonline.com";
    /**
     * APIM SSO Path-Segment to get a fresh "Bearer" authorization token.
     */
    public static final String SSO_HOST_TOKEN_PATH = "/auth/realms/SBB_Public/protocol/openid-connect/token";

    public static final String CLIENT_ID = "clientId";
    public static final String APIM_AZURE_CLIENTID = "azp";

    public static final String APIM_AZURE_CLIENT_ROLES = "roles";

    public static final String TOKEN_EXPIRATION_DATE = "exp";

    public static final String GRANT_TYPE = "grant_type";
    public static final String CLIENT_CREDENTIALS = "client_credentials";
}
