package ch.sbb.backend.arch;

import ch.sbb.backend.DASBackendApplication;
import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ModularityTests {

    @Test
    void verifiesModularStructure() {
        ApplicationModules modules = ApplicationModules.of(DASBackendApplication.class);
        modules.forEach(System.out::println);
        modules.verify();
    }
}
