package ch.sbb.das.backend.admin.application.settings;

import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import org.jspecify.annotations.NonNull;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.test.context.support.WithSecurityContextFactory;

/**
 * Factory that creates a security context with a JWT authentication token for use with the {@link WithMockRole} annotation.
 */
public class WithMockRoleSecurityContextFactory implements WithSecurityContextFactory<WithMockRole> {

    private static final String ADMIN_TENANT = "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a";
    private static final String OTHER_TENANT = "3409e798-d567-49b1-9bae-f0be66427c54";

    @Override
    @NonNull
    public SecurityContext createSecurityContext(@NonNull WithMockRole annotation) {
        String tenantId = annotation.adminTenant() ? ADMIN_TENANT : OTHER_TENANT;
        List<SimpleGrantedAuthority> authorities = Arrays.stream(annotation.roles())
            .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
            .toList();

        Jwt jwt = Jwt.withTokenValue("token")
            .header("alg", "none")
            .issuer("https://login.microsoftonline.com/" + tenantId + "/v2.0")
            .subject("test-user")
            .issuedAt(Instant.now())
            .expiresAt(Instant.now().plusSeconds(3600))
            .build();

        Authentication authentication = new JwtAuthenticationToken(jwt, authorities);

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authentication);
        return context;
    }
}

