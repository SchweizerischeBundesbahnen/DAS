package ch.sbb.playgroundbackend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {

    @GetMapping
    String get() {
        return "Hello DAS Test";
    }

}
