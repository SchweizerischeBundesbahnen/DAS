package ch.sbb.das.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.server.servlet.context.ServletComponentScan;

@ServletComponentScan
@SpringBootApplication
public class DASBackendApplication {

    static void main(String[] args) {
        SpringApplication.run(DASBackendApplication.class, args);
    }

}
