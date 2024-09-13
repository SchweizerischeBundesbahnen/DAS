package ch.sbb.sferamock.config;

import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class CorsConfig {

    @Value("${endpoints.web.cors.path-mappings}")
    private String pathMappings;
    @Value("${endpoints.web.cors.allowed-origins}")
    private List<String> allowedOrigins;
    @Value("${endpoints.web.cors.allowed-methods}")
    private List<String> allowedMethods;
    @Value("${endpoints.web.cors.allowed-headers}")
    private List<String> allowedHeaders;

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(allowedOrigins);
        configuration.setAllowedMethods(allowedMethods);
        configuration.setAllowedHeaders(allowedHeaders);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration(pathMappings, configuration);
        return source;
    }
}
