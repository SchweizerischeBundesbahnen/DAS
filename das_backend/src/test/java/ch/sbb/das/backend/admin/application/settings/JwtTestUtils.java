package ch.sbb.das.backend.admin.application.settings;

import java.time.Instant;
import java.util.List;
import lombok.experimental.UtilityClass;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;

@UtilityClass
public class JwtTestUtils {

    private static final String ADMIN_TENANT = "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a";
    private static final String OTHER_TENANT = "3409e798-d567-49b1-9bae-f0be66427c54";

    public static JwtAuthenticationToken createAdminTenantAuth() {
        return createJwtAuth(ADMIN_TENANT);
    }

    public static Authentication createOtherTenantAuth() {
        return createJwtAuth(OTHER_TENANT);
    }

    private static JwtAuthenticationToken createJwtAuth(String tenantId) {
        Jwt jwt = Jwt.withTokenValue("token")
            .header("alg", "none")
            .issuer("https://login.microsoftonline.com/" + tenantId + "/v2.0")
            .subject("test-user")
            .issuedAt(Instant.now())
            .expiresAt(Instant.now().plusSeconds(3600))
            .build();

        return new JwtAuthenticationToken(
            jwt,
            List.of(new SimpleGrantedAuthority("ROLE_admin"))
        );
    }

}

