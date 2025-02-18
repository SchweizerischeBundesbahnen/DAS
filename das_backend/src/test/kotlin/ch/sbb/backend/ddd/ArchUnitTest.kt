package ch.sbb.backend.ddd

import com.tngtech.archunit.core.importer.ImportOption
import com.tngtech.archunit.junit.AnalyzeClasses
import com.tngtech.archunit.junit.ArchTest
import com.tngtech.archunit.lang.ArchRule
import com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses
import com.tngtech.archunit.library.Architectures.layeredArchitecture
import com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices


@AnalyzeClasses(
    packages = ["ch.sbb.backend"],
    importOptions = [ImportOption.DoNotIncludeTests::class]
)
class ArchUnitTest {

    @ArchTest
    val CORRECT_LAYERED_ARCHITECTURE: ArchRule = layeredArchitecture()
        .consideringAllDependencies()
        .layer("infrastructure").definedBy("..infrastructure..")
        .layer("application").definedBy("..application..")
        .layer("domain").definedBy("..domain..")
        .whereLayer("infrastructure").mayOnlyBeAccessedByLayers("infrastructure")
        .whereLayer("application").mayOnlyBeAccessedByLayers("infrastructure")
        .whereLayer("domain").mayOnlyBeAccessedByLayers("infrastructure", "application")

    @ArchTest
    val APPLICATION_FREE_OF_CYCLES: ArchRule = slices()
        .matching("..application.(**)")
        .should().beFreeOfCycles()

    @ArchTest
    val DOMAIN_FREE_OF_CYCLES: ArchRule = slices()
        .matching("..domain.(**)")
        .should().beFreeOfCycles()

    @ArchTest
    val INFRASTRUCTURE_FREE_OF_CYCLES: ArchRule = slices()
        .matching("..infrastructure.(**)")
        .should().beFreeOfCycles()

    @ArchTest
    val NO_FRAMEWORK_CODE_IN_DOMAIN: ArchRule = noClasses()
        .that().resideInAPackage("..domain..")
        .should().dependOnClassesThat().resideOutsideOfPackages(
            "ch.sbb..",
            "java..",
            "javax..",
            "org.slf4j..",
            "kotlin..",
            "org.jetbrains.annotations.."
        )
        .because("our domain core should be independent of frameworks")
}
