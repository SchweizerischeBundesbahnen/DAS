package ch.sbb.backend.admin.application;

import ch.sbb.backend.admin.application.model.ServicePointResponse;
import ch.sbb.backend.admin.domain.service.ServicePointService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("api/v1/service-points")
@Tag(name = "Service Points", description = "API for service points")
public class ServicePointsController {

    private final ServicePointService servicePointService;

    public ServicePointsController(ServicePointService servicePointService) {
        this.servicePointService = servicePointService;
    }

    @Operation(summary = "Get all service points")
    @ApiResponse(responseCode = "200", description = "Service points successfully retrieved")
    @ApiResponse(responseCode = "400", description = "Invalid input",
        content = {@Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse"))})
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "500", description = "Internal server error",
        content = {@Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse"))})
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity<List<ServicePointResponse>> getAllServicePoints() {
        return ResponseEntity.ok(servicePointService.getAll().stream().map(sp -> new ServicePointResponse(sp.uic(), sp.designation(), sp.abbreviation())).toList());
    }

    @Operation(summary = "Get service point by UIC")
    @ApiResponse(responseCode = "200", description = "Service point successfully retrieved")
    @ApiResponse(responseCode = "400", description = "Invalid input",
        content = {@Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse"))})
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "404", description = "Service point not found", content = @Content(schema = @Schema(hidden = true)))
    @ApiResponse(responseCode = "500", description = "Internal server error",
        content = {@Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse"))})
    @GetMapping(path = "/{uic}", produces = MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity<ServicePointResponse> getServicePoint(@PathVariable int uic) {
        return servicePointService.findByUic(uic).map(servicePoint -> ResponseEntity.ok(new ServicePointResponse(servicePoint.uic(), servicePoint.designation(), servicePoint.abbreviation())))
            .orElse(ResponseEntity.notFound().build());
    }
}
