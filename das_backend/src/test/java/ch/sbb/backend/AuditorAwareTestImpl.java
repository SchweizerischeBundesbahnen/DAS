package ch.sbb.backend;

import java.util.Optional;
import org.jetbrains.annotations.NotNull;
import org.springframework.data.domain.AuditorAware;

/**
 * Fakes user because no token at test-time available to fill in @LastModifiedBy automatically.
 */
public class AuditorAwareTestImpl implements AuditorAware<String> {

    public static final String LAST_MODIFIED_BY = "unit_test";

    @NotNull
    @Override
    public Optional<String> getCurrentAuditor() {
        return Optional.of(LAST_MODIFIED_BY);
    }
}