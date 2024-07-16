package ch.sbb.playgroundbackend.config;

import static org.springframework.security.config.Customizer.withDefaults;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@Profile("!test")
public class WebSecurityConfiguration {

    private static final String ROLES_KEY = "roles";
    private static final String ROLE_PREFIX = "ROLE_";

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(withDefaults())
            .authorizeHttpRequests(authConfig -> {
                    authConfig.requestMatchers("/swagger-ui/**").permitAll();
                    authConfig.requestMatchers("/v3/api-docs/**").permitAll();
                    authConfig.requestMatchers("/actuator/health/*").permitAll();
                    authConfig.requestMatchers("/actuator/info").permitAll();
                    authConfig.requestMatchers("/admin/**").hasRole("admin");
                    authConfig.requestMatchers("/**").authenticated();
                }
            )
            // Disable csrf for now as it makes unauthenticated requests return 401/403
            .csrf(AbstractHttpConfigurer::disable)
            .oauth2ResourceServer(oauth2 ->
                oauth2.jwt(jwtConfigurer -> jwtConfigurer.jwtAuthenticationConverter(jwtAuthenticationConverter()))
            );
        return http.build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        // We define a custom role converter to extract the roles from the Entra ID's JWT token and convert them to granted authorities.
        // This allows us to do role-based access control on our endpoints.
        JwtGrantedAuthoritiesConverter roleConverter = new JwtGrantedAuthoritiesConverter();
        roleConverter.setAuthoritiesClaimName(ROLES_KEY);
        roleConverter.setAuthorityPrefix(ROLE_PREFIX);

        JwtAuthenticationConverter jwtAuthenticationConverter = new JwtAuthenticationConverter();
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(roleConverter);

        return jwtAuthenticationConverter;
    }
}
