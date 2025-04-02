package ch.sbb.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;

@ServletComponentScan
@SpringBootApplication
public class DASBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(DASBackendApplication.class, args);
    }

}
