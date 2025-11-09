package ch.sbb.das.backend.restapi.iam.ssoutils;

import java.net.URI;
import lombok.NonNull;
import lombok.Value;
import org.springframework.http.HttpMethod;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Value
public class RestRequestInfo {

    @NonNull HttpMethod requestMethod;
    @NonNull URI requestUri;
    Object requestBody;
}
