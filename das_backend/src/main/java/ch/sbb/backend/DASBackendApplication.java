package ch.sbb.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.server.servlet.context.ServletComponentScan;
import org.springframework.retry.annotation.EnableRetry;

@ServletComponentScan
@SpringBootApplication
@EnableRetry
public class DASBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(DASBackendApplication.class, args);
    }

}
