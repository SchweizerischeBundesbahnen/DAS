package ch.sbb.backend.ddd

import ch.sbb.backend.BackendApplication
import org.junit.jupiter.api.Test
import org.springframework.modulith.core.ApplicationModules

class ModularityTests {

    @Test
    fun verifiesModularStructure() {
        val modules: ApplicationModules = ApplicationModules.of(BackendApplication::class.java)
        modules.forEach { println(it) }
        modules.verify()
    }
}
