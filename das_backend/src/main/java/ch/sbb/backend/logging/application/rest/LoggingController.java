package ch.sbb.backend.logging.application.rest;

import ch.sbb.backend.logging.application.model.request.LogEntry;
import ch.sbb.backend.logging.domain.service.LoggingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "v1/logging")
@Tag(name = "Logging", description = "API for logging")
class LoggingController {

    LoggingService loggingService;

    public LoggingController(LoggingService loggingService) {
        this.loggingService = loggingService;
    }

    // TODO: deprecated: has to be reworked (#769)
    @Operation(summary = "Log messages from clients", deprecated = true)
    @ApiResponse(responseCode = "200", description = "Logs successfully saved")
    @ApiResponse(responseCode = "400", description = "Invalid input",
        content = {@Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse"))})
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "500", description = "Internal server error",
        content = {@Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse"))})
    @PostMapping(value = "/logs", consumes = "application/json")
    void logs(@RequestBody List<@Valid LogEntry> logs) {
        loggingService.saveAll(logs.stream().map(LogEntry::toLogEntry).toList());
    }
}
