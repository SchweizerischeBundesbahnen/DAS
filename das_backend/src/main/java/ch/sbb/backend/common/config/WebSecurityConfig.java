package ch.sbb.backend.common.config;

import static ch.sbb.backend.admin.application.settings.SettingsController.API_SETTINGS;
import static ch.sbb.backend.formation.api.v1.FormationController.API_FORMATIONS;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Production security.
 *
 * @see JWTConfig
 */
@Configuration
@Profile("!local-no-docker")
@EnableWebSecurity
@EnableMethodSecurity
public class WebSecurityConfig {

    public static final String ROLE_OBSERVER = "observer";
    public static final String ROLE_DRIVER = "driver";
    public static final String ROLE_RU_ADMIN = "ru_admin";
    public static final String ROLE_ADMIN = "admin";

    @Autowired
    JwtAuthenticationConverter jwtAuthenticationConverter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http.authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .requestMatchers("/actuator/health/**").permitAll()
                .requestMatchers(API_SETTINGS, API_FORMATIONS).hasAnyRole(ROLE_OBSERVER, ROLE_DRIVER)
                .anyRequest().authenticated()
            )
            .csrf(AbstractHttpConfigurer::disable)
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter))
            );
        return http.build();
    }
}

