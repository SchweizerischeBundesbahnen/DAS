package ch.sbb.backend.logging.application.rest

import ch.sbb.backend.logging.domain.service.LoggingService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Validated
@RestController
@RequestMapping("api/v1/logging")
@Tag(name = "Logging", description = "API for logging")
class LoggingController(private val loggingService: LoggingService) {

    @Operation(summary = "Log messages from clients")
    @ApiResponse(responseCode = "200", description = "Logs successfully saved")
    @ApiResponse(
        responseCode = "400", description = "Invalid input", content = [
            Content(
                mediaType = "application/json",
                schema = Schema(ref = "#/components/schemas/ErrorResponse")
            )
        ]
    )
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(
        responseCode = "500", description = "Internal server error", content = [
            Content(
                mediaType = "application/json",
                schema = Schema(ref = "#/components/schemas/ErrorResponse")
            )
        ]
    )
    @PostMapping("/logs", consumes = ["application/json"])
    fun logs(@RequestBody logs: List<LogEntryRequest>) {
        loggingService.saveAll(logs.map { it.toLogEntry() })
    }
}
