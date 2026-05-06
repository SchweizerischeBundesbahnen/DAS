package ch.sbb.das.backend.common.config;

import static ch.sbb.das.backend.admin.application.holidays.HolidayController.API_HOLIDAYS;
import static ch.sbb.das.backend.admin.application.locations.TafTapLocationController.API_LOCATIONS;
import static ch.sbb.das.backend.admin.application.notices.NoticeTemplateController.API_NOTICE_TEMPLATES;
import static ch.sbb.das.backend.admin.application.settings.AppVersionController.API_SETTINGS_APP_VERSION;
import static ch.sbb.das.backend.admin.application.settings.SettingsController.API_SETTINGS;
import static ch.sbb.das.backend.formation.api.v1.FormationController.API_FORMATIONS;
import static ch.sbb.das.backend.proxy.CustomerOrientedDepartureController.API_CUSTOMER_ORIENTED_DEPARTURE;
import static org.springframework.security.config.Customizer.withDefaults;

import ch.sbb.das.backend.common.security.UserRole;
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

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, JwtAuthenticationConverter jwtAuthenticationConverter) {
        http.authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .requestMatchers("/actuator/health/**").permitAll()
                .requestMatchers(API_SETTINGS, API_FORMATIONS, API_CUSTOMER_ORIENTED_DEPARTURE + "/**").hasAnyRole(UserRole.OBSERVER, UserRole.DRIVER)
                .requestMatchers(API_SETTINGS_APP_VERSION + "/**", API_LOCATIONS).hasRole(UserRole.ADMIN)
                .requestMatchers(API_NOTICE_TEMPLATES + "/**", API_HOLIDAYS + "/**").hasAnyRole(UserRole.ADMIN, UserRole.RU_ADMIN)
                .anyRequest().authenticated()
            )
            .csrf(AbstractHttpConfigurer::disable)
            .cors(withDefaults())
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter))
            );
        return http.build();
    }
}

