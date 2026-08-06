package ch.sbb.das.backend.arch;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.methods;

import com.tngtech.archunit.core.domain.JavaMethod;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchCondition;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.lang.ConditionEvents;
import com.tngtech.archunit.lang.SimpleConditionEvent;
import org.junit.jupiter.api.DisplayName;

@AnalyzeClasses(packages = "ch.sbb.das.backend", importOptions = ImportOption.OnlyIncludeTests.class)
final class ArchUnitDisplayNameTest {

    @ArchTest
    static final ArchRule IT_TEST_METHODS_MUST_HAVE_DISPLAY_NAMES_WITH_REFERENCES = methods()
        .that().haveNameMatching(".*(ControllerTest|IntegrationTest)$")
        .or().areDeclaredInClassesThat().haveNameMatching(".*(ControllerTest|IntegrationTest)$")
        .and().areAnnotatedWith(org.junit.jupiter.api.Test.class)
        .should(checkDisplayNameConvention());

    private static ArchCondition<JavaMethod> checkDisplayNameConvention() {
        return new ArchCondition<>("have a @DisplayName containing '<methodName>|<ID>|tests:<value>'") {
            @Override
            public void check(JavaMethod method, ConditionEvents events) {
                if (!method.isAnnotatedWith(DisplayName.class)) {
                    events.add(SimpleConditionEvent.violated(method, String.format("Method %s is missing @DisplayName", method.getFullName())));
                    return;
                }

                String value = method.getAnnotationOfType(DisplayName.class).value();

                // Expected format: methodName|<20-char-alphanumeric-ID>|tests:<ids>
                if (!value.matches("^[^|]+\\|[A-Za-z0-9]{20}\\|tests:.+$")) {
                    events.add(SimpleConditionEvent.violated(method, String.format(
                        "Method %s has invalid @DisplayName format: '%s'. Expected: '<methodName>|<20-char-ID>|tests:<ids>'",
                        method.getFullName(), value)));
                    return;
                }

                // Method name must match the first segment of @DisplayName
                String displayNamePrefix = value.substring(0, value.indexOf('|'));
                if (!displayNamePrefix.equals(method.getName())) {
                    events.add(SimpleConditionEvent.violated(method, String.format(
                        "Method %s has mismatched @DisplayName prefix: '%s' (expected '%s'). Run: node scripts/java_test_display_names.mjs",
                        method.getFullName(), displayNamePrefix, method.getName())));
                }
            }
        };
    }
}
