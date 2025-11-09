package ch.sbb.das.backend.restapi.iam.ssoutils;

import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.RequestScope;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Component
@RequestScope
@Getter
@Setter
public class RequestContextHolder {

    /**
     * Concrete Request-Context, within Request
     */
    private RequestContext requestContext;
}
