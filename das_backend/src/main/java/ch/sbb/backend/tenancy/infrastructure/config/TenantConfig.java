package ch.sbb.backend.tenancy.infrastructure.config;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import java.util.List;
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
public class TenantConfig {

    private List<Tenant> tenants;

}
