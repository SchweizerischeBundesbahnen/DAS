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
        return new ArchCondition<>("have a @DisplayName containing '|tests:<value>'") {
            @Override
            public void check(JavaMethod method, ConditionEvents events) {
                if (!method.isAnnotatedWith(DisplayName.class)) {
                    events.add(SimpleConditionEvent.violated(method, String.format("Method %s is missing @DisplayName", method.getFullName())));
                    return;
                }

                String value = method.getAnnotationOfType(DisplayName.class).value();

                int index = value.indexOf("|tests:");
                boolean isValid = index != -1 && (index + "|tests:".length() < value.length());

                if (!isValid) {
                    events.add(SimpleConditionEvent.violated(method, String.format("Method %s is missing issue reference(s) in @DisplayName: '%s'", method.getFullName(), value)));
                }
            }
        };
    }
}
