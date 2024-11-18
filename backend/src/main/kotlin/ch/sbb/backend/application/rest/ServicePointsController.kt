package ch.sbb.backend.application.rest

import ch.sbb.backend.infrastructure.services.ServicePointsService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType.APPLICATION_JSON_VALUE
import org.springframework.http.ResponseEntity
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.*

@Validated
@RestController
@RequestMapping("api/v1/service-points")
@Tag(name = "Service Points", description = "API for service points")
class ServicePointsController(private val servicePointsService: ServicePointsService) {

    @Operation(summary = "Update service points")
    @ApiResponse(responseCode = "200", description = "Service points successfully updated")
    @ApiResponse(
        responseCode = "400", description = "Invalid input", content = [
            Content(
                mediaType = APPLICATION_JSON_VALUE,
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
    @PutMapping(consumes = ["application/json"])
    fun updateServicePoints(@RequestBody servicePoints: List<ServicePointDto>) {
        servicePointsService.update(servicePoints)
    }

    @Operation(summary = "Get all service points")
    @ApiResponse(responseCode = "200", description = "Service points successfully retrieved")
    @ApiResponse(
        responseCode = "401",
        description = "Unauthorized",
        content = [Content(schema = Schema(hidden = true))]
    )
    @ApiResponse(
        responseCode = "500", description = "Internal server error", content = [
            Content(
                mediaType = "application/json",
                schema = io.swagger.v3.oas.annotations.media.Schema(ref = "#/components/schemas/ErrorResponse")
            )
        ]
    )
    @ResponseBody
    @GetMapping(produces = [APPLICATION_JSON_VALUE])
    fun getAllServicePoints(): ResponseEntity<List<ServicePointDto>> {
        return ResponseEntity.ok(servicePointsService.getAll())
    }

    @Operation(summary = "Get service point by UIC")
    @ApiResponse(responseCode = "200", description = "Service point successfully retrieved")
    @ApiResponse(
        responseCode = "401",
        description = "Unauthorized",
        content = [Content(schema = Schema(hidden = true))]
    )
    @ApiResponse(
        responseCode = "404",
        description = "Service point not found",
        content = [Content(schema = Schema(hidden = true))]
    )
    @ApiResponse(
        responseCode = "500", description = "Internal server error", content = [
            Content(
                mediaType = "application/json",
                schema = Schema(ref = "#/components/schemas/ErrorResponse")
            )
        ]
    )
    @ResponseBody
    @GetMapping("/{uic}", produces = [APPLICATION_JSON_VALUE])
    fun getServicePoint(@PathVariable uic: Int): ResponseEntity<ServicePointDto> {
        return servicePointsService.getByUic(uic)?.let { ResponseEntity.ok(it) }
            ?: ResponseEntity.notFound().build()
    }
}
