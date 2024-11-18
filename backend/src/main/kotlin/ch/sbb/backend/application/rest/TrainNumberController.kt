package ch.sbb.backend.application.rest

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
@RequestMapping("api/v1/train-numbers")
@Tag(name = "Train numbers", description = "API for train numbers")
class TrainNumberController {

    @Operation(summary = "Add train numbers")
    @ApiResponse(responseCode = "200", description = "Train numbers successfully added")
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
    @PostMapping(consumes = ["application/json"])
    fun addTrainNumbers(@RequestBody trainNumbers: List<TrainNumberDto>) {

    }

    @Operation(summary = "Get all train numbers")
    @ApiResponse(responseCode = "200", description = "Train numbers successfully retrieved")
    @ApiResponse(
        responseCode = "401",
        description = "Unauthorized",
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
    @GetMapping(produces = [APPLICATION_JSON_VALUE])
    fun getAllTrainNumbers(): ResponseEntity<List<TrainNumberDto>> {
        return ResponseEntity.ok().build()
    }
}
