package ch.sbb.das.backend.restapi.e2etest.helper;

import lombok.Getter;
import org.junit.jupiter.api.extension.BeforeEachCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

/**
 * Make accessible the test's ExtensionContext at any time in the test.
 * <p>
 * Alternatively use a {@code @Before void setTestInfo(TestInfo testInfo) ... } and access {@link org.junit.jupiter.api.TestInfo#getDisplayName() testInfo.getDisplayName()} or other info.
 */
public class TestContextGetterExtension implements BeforeEachCallback {

    @Getter
    private ExtensionContext context;

    @Override
    public void beforeEach(ExtensionContext context) {
        this.context = context;
    }
}
