package ch.sbb.das.backend.common.config;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ClockConfiguration {

    @Bean
    public Clock clock() {
        return Clock.system(DateTimeUtil.SWISS_ZONE);
    }
}
