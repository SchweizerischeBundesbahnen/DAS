package ch.sbb.das.backend.restapi.configuration;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

@Slf4j
@Configuration
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend_SAMPLE.properties")
// override sample with concrete env settings
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend.properties", ignoreResourceNotFound = true)
public class DasBackendEndpointConfiguration {

    @Value("${das.backend.endpoint}")
    private String endpoint;
    @Value("${das.backend.port:}")
    private String port;

    @Bean
    public DasBackendEndpoint createEndpointConfiguration() {
        final DasBackendEndpoint backendEndpoint = DasBackendEndpoint.builder()
            .endpoint(endpoint)
            .port(port)
            .build();

        if (backendEndpoint.isLocalHost()) {
            log.info("localhost data under test");
        } else if (backendEndpoint.isDev()) {
            log.info("DEV data under test");
        } else {
            log.warn("Environment under test unclear");
        }

        return backendEndpoint;
    }

    public String getEndpoint() {
        return endpoint + ":" + port;
    }
}
