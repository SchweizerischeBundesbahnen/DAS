package ch.sbb.backend.tours.application

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType.APPLICATION_JSON_VALUE
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Validated
@RestController
@RequestMapping("api/v1/tours")
@Tag(name = "Tours", description = "API for tours")
class ToursController {

    @Operation(summary = "Update tours")
    @ApiResponse(responseCode = "200", description = "Tours successfully updated")
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
    fun updateTours(@RequestBody tours: List<TourDto>) {

    }
}
