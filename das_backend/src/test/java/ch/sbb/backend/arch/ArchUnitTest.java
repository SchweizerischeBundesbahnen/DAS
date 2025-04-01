package ch.sbb.backend.arch;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.library.Architectures.layeredArchitecture;
import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

@AnalyzeClasses(packages = "ch.sbb.backend", importOptions = ImportOption.DoNotIncludeTests.class)
final class ArchUnitTest {

    @ArchTest
    static final ArchRule CORRECT_LAYERED_ARCHITECTURE = layeredArchitecture()
        .consideringAllDependencies()
        .layer("infrastructure").definedBy("..infrastructure..")
        .layer("application").definedBy("..application..")
        .layer("domain").definedBy("..domain..")
        .whereLayer("infrastructure").mayOnlyBeAccessedByLayers("infrastructure")
        .whereLayer("application").mayOnlyBeAccessedByLayers("infrastructure")
        .whereLayer("domain").mayOnlyBeAccessedByLayers("infrastructure", "application");

    @ArchTest
    static final ArchRule APPLICATION_FREE_OF_CYCLES = slices()
        .matching("..application.(**)")
        .should().beFreeOfCycles();

    @ArchTest
    static final ArchRule DOMAIN_FREE_OF_CYCLES = slices()
        .matching("..domain.(**)")
        .should().beFreeOfCycles();

    @ArchTest
    static final ArchRule INFRASTRUCTURE_FREE_OF_CYCLES = slices()
        .matching("..infrastructure.(**)")
        .should().beFreeOfCycles();

    @ArchTest
    static final ArchRule NO_FRAMEWORK_CODE_IN_DOMAIN = noClasses()
        .that().resideInAPackage("..domain..")
        .should().dependOnClassesThat().resideOutsideOfPackages(
            "ch.sbb..",
            "java..",
            "javax..",
            "org.slf4j..",
            "kotlin..",
            "org.jetbrains.annotations.."
        )
        .because("our domain core should be independent of frameworks");
}
