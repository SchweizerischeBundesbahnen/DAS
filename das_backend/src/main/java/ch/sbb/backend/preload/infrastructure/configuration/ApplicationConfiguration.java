package ch.sbb.backend.preload.infrastructure.configuration;

import java.util.Map;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "preload")
public class ApplicationConfiguration {

    @Getter
    @Setter
    Map<String, String> uicCompanyCodes;
}
