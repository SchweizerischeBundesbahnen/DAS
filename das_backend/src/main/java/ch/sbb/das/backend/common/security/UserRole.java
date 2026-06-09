package ch.sbb.das.backend.common.security;

import lombok.experimental.UtilityClass;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Arrays;
import java.util.Objects;

@UtilityClass
public final class UserRole {
    private static final String ROLE_PREFIX = "ROLE_";

    public static final String OBSERVER = "observer";
    public static final String DRIVER = "driver";
    public static final String RU_ADMIN = "ru_admin";
    public static final String ADMIN = "admin";

    public static boolean hasRole(String... roles) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return false;
        }

        return Arrays.stream(roles)
                .map(role -> ROLE_PREFIX + role)
                .anyMatch(roleString -> authentication.getAuthorities().stream()
                        .anyMatch(authority -> Objects.equals(authority.getAuthority(), roleString)));
    }
}
