package ch.sbb.das.preload

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.boot.web.servlet.ServletComponentScan

@ServletComponentScan
@SpringBootApplication
class PreloadApplication

fun main(args: Array<String>) {
    runApplication<PreloadApplication>(*args)
}
