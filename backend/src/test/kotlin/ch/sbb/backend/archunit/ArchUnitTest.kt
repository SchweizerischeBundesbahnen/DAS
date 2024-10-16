package ch.sbb.backend.archunit

import com.tngtech.archunit.junit.AnalyzeClasses
import com.tngtech.archunit.junit.ArchTest
import com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes

@AnalyzeClasses(packages = ["ch.sbb.backend"])
class ArchUnitTest {

    @ArchTest
    val `controller classes should be in application` = classes()
        .that().haveSimpleNameEndingWith("Controller")
        .should().resideInAPackage("..application..")
}
