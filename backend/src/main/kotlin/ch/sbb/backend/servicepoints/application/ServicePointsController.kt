package ch.sbb.backend.servicepoints.application

import ch.sbb.backend.servicepoints.domain.service.ServicePointService
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
class ServicePointsController(private val servicePointService: ServicePointService) {

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
    fun getAllServicePoints(): ResponseEntity<List<ServicePointReponse>> {
        return ResponseEntity.ok(servicePointService.getAll().map { ServicePointReponse(it.uic, it.designation, it.abbreviation) })
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
    fun getServicePoint(@PathVariable uic: Int): ResponseEntity<ServicePointReponse> {
        return servicePointService.findByUic(uic)?.let { ResponseEntity.ok(ServicePointReponse(it.uic, it.abbreviation, it.designation)) }
            ?: ResponseEntity.notFound().build()
    }
}
