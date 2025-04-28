package ch.sbb.backend;

import java.util.Optional;
import org.springframework.data.domain.AuditorAware;

public class AuditorAwareTestImpl implements AuditorAware<String> {

    @Override
    public Optional<String> getCurrentAuditor() {
        return Optional.of("unit_test");
    }
}