package ch.sbb.das.backend.tenancy.infrastructure.config;

import ch.sbb.das.backend.tenancy.domain.model.Tenant;
import java.util.List;
import java.util.Map;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Setter
@Getter
@Configuration
@EnableConfigurationProperties
@ConfigurationProperties(prefix = "auth")
public class ApplicationConfiguration {

    private List<Tenant> tenants;
    private String adminTenantId;
    Map<String, String> companyCodes;
}
