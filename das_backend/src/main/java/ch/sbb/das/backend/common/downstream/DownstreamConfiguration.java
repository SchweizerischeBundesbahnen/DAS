package ch.sbb.das.backend.common.downstream;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * Everything a downstream client needs; a {@code @RestClientTest} imports this.
 */
@Configuration
@EnableConfigurationProperties(DownstreamProperties.class)
@Import({DownstreamRestClients.class, DownstreamCalls.class})
public class DownstreamConfiguration {

}
