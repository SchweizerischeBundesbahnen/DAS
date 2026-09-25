package ch.sbb.das.backend.useractivity.internal;

import ch.sbb.das.backend.useractivity.UserActivityService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Records user activity for read (GET) requests against personal-data endpoints.
 */
@Component
@RequiredArgsConstructor
class UserActivityInterceptor implements HandlerInterceptor {

    private static final String OID_CLAIM = "oid";

    private final UserActivityService userActivityService;

    @Override
    public void afterCompletion(HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull Object handler, Exception ex) {
        if (!HttpMethod.GET.matches(request.getMethod())) {
            return;
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication instanceof JwtAuthenticationToken jwtAuthentication) {
            String oid = jwtAuthentication.getToken().getClaimAsString(OID_CLAIM);
            userActivityService.recordAccess(oid);
        }
    }
}
