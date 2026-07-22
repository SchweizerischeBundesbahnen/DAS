package ch.sbb.das.backend.arch;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@AnalyzeClasses(packages = "ch.sbb.das.backend", importOptions = ImportOption.DoNotIncludeTests.class)
final class ArchUnitDateTimeUtilTest {

    @ArchTest
    static final ArchRule USE_DATE_TIME_UTIL = noClasses()
        .should()
        .callMethod(LocalDate.class, "now")
        .orShould()
        .callMethod(OffsetDateTime.class, "now")
        .because("Use DateTimeUtil with provided zone information");
}
