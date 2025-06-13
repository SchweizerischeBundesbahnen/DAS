package ch.sbb.backend;

import io.swagger.v3.oas.models.servers.Server;
import java.util.List;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApiConfig {

    @Bean
    public OpenApiCustomizer openApiCustomizer() {
        return openApi -> openApi.servers(List.of(new Server().url("@@user.api.public@@").description("Generated server url")));
    }
}
