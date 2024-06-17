package ch.sbb.playgroundbackend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

import static org.springframework.security.config.Customizer.withDefaults;

@Configuration
@EnableWebSecurity
@Profile("!test")
public class WebSecurityConfiguration {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests((authConfig) -> {
                            authConfig.requestMatchers("/swagger-ui/**").permitAll();
                            authConfig.requestMatchers("/v3/api-docs/**").permitAll();
                            authConfig.requestMatchers("/actuator/health/*").permitAll();
                            authConfig.requestMatchers("/actuator/info").permitAll();
                            authConfig.requestMatchers("/customClaim").permitAll();
                            authConfig.requestMatchers("/**").authenticated();
                        }
                )
                // Disable csrf for now as it makes unauthenticated requests return 401/403
                .csrf(AbstractHttpConfigurer::disable)
                .oauth2ResourceServer((oauth2) ->
                        oauth2.jwt(withDefaults())
                );
        return http.build();
    }
}
