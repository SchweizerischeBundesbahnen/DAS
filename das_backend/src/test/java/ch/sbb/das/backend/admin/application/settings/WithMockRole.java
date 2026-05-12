package ch.sbb.das.backend.admin.application.settings;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.security.test.context.support.WithSecurityContext;

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@WithSecurityContext(factory = WithMockRoleSecurityContextFactory.class)
public @interface WithMockRole {

    /**
     * Whether the JWT should use the admin tenant. If false, a non-admin tenant is used.
     */
    boolean adminTenant() default true;

    /**
     * The roles to grant to the authenticated user. Default is ROLE_admin.
     */
    String[] roles() default {};
}


