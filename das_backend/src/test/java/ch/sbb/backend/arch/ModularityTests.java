package ch.sbb.backend.arch;

import ch.sbb.backend.BackendApplication;
import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ModularityTests {

    @Test
    void verifiesModularStructure() {
        ApplicationModules modules = ApplicationModules.of(BackendApplication.class);
        modules.forEach(System.out::println);
        modules.verify();
    }
}
