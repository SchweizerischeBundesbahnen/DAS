package ch.sbb.das.backend.restapi.configuration;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.PropertySource;

@Profile({"das"})
@Configuration //(basePackageClasses = {EnvironmentProperties.class})
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend_SAMPLE.properties")
// override sample with local settings where needed
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend.properties", ignoreResourceNotFound = true)
public class DasBackendEndpointConfiguration {

    @Value("${das-backend.endpoint:}")
    private String endpoint;
    @Value("${das-backend.port:}")
    private String port;

    @Getter
    @Autowired
    private SSOConfiguration ssoConfiguration;

    @Bean
    public DasBackendEndpoint createEndpointConfiguration() {
        return DasBackendEndpoint.builder()
            .endpoint(endpoint)
            .port(port)
            .build();
    }

    public String getEndpoint() {
        return endpoint + ":" + port;
    }
}
