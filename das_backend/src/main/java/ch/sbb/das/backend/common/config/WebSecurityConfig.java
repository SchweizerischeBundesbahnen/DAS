package ch.sbb.das.backend.common.config;

import static ch.sbb.das.backend.appversions.internal.AppVersionController.API_APP_VERSIONS;
import static ch.sbb.das.backend.companies.internal.CompanyController.API_COMPANIES;
import static ch.sbb.das.backend.departures.internal.DepartureController.API_DEPARTURES;
import static ch.sbb.das.backend.driversettings.internal.SettingsController.API_SETTINGS;
import static ch.sbb.das.backend.externallinks.internal.ExternalLinkController.API_ADMIN_EXTERNAL_LINKS;
import static ch.sbb.das.backend.externallinks.internal.ExternalLinkController.API_DRIVER_EXTERNAL_LINKS;
import static ch.sbb.das.backend.formation.api.v1.FormationController.API_FORMATIONS;
import static ch.sbb.das.backend.indications.internal.RuIndicationController.API_DRIVER_RU_INDICATIONS;
import static ch.sbb.das.backend.indications.internal.RuIndicationController.API_RU_INDICATIONS;
import static ch.sbb.das.backend.indications.internal.RuIndicationTemplateController.API_RU_INDICATION_TEMPLATES;
import static ch.sbb.das.backend.indications.internal.SpecialHolidayController.API_SPECIAL_HOLIDAYS;
import static ch.sbb.das.backend.locations.internal.TafTapLocationController.API_LOCATIONS;
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
                .requestMatchers(API_SETTINGS, API_FORMATIONS, API_DEPARTURES + "/**", API_DRIVER_RU_INDICATIONS, API_DRIVER_EXTERNAL_LINKS)
                .hasAnyRole(UserRole.OBSERVER, UserRole.DRIVER)
                .requestMatchers(API_APP_VERSIONS + "/**", API_LOCATIONS)
                .hasRole(UserRole.ADMIN)
                .requestMatchers(API_RU_INDICATION_TEMPLATES + "/**", API_SPECIAL_HOLIDAYS + "/**", API_RU_INDICATIONS + "/**", API_ADMIN_EXTERNAL_LINKS + "/**", API_COMPANIES)
                .hasAnyRole(UserRole.ADMIN, UserRole.RU_ADMIN)
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
