package ch.sbb.backend.application.rest

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.constraints.Size
import org.springframework.http.MediaType.APPLICATION_JSON_VALUE
import org.springframework.http.ResponseEntity
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.*
import java.time.LocalDate

@Validated
@RestController
@RequestMapping("api/v1/train-identifiers")
@Tag(name = "Train identifiers", description = "API for train identifiers")
class TrainIdentifierController {

    @Operation(summary = "Update/add train identifier")
    @ApiResponse(responseCode = "200", description = "Train identifier successfully added")
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
//    todo api spec path ru
    @PutMapping(path = ["/{ru}"], consumes = ["application/json"])
    fun updateTrainIdentifier(
        @Parameter(description = "Identifies a railway undertaking code (UIC RICS Code: https://uic.org/rics)")
        @PathVariable("ru") @Size(min= 4, max = 4) ru: String, @RequestBody trainIdentifier: TrainIdentifierDto) {
        println("$ru $trainIdentifier")

    }

    @Operation(summary = "Batch update/add train identifiers")
    @ApiResponse(responseCode = "200", description = "Train identifier successfully updated")
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
    @PutMapping(path = ["/{ru}/batch"], consumes = ["application/json"])
    fun batchUpdateTrainIdentifiers(@PathVariable("ru") @Size(min= 4, max = 4) ru: String, @RequestBody trainIdentifiers: List<TrainIdentifierDto>) {
        println("$ru $trainIdentifiers")
    }

    @Operation(summary = "Delete train identifier")
    @ApiResponse(responseCode = "200", description = "Train identifier successfully deleted")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(
        responseCode = "500", description = "Internal server error", content = [
            Content(
                mediaType = "application/json",
                schema = Schema(ref = "#/components/schemas/ErrorResponse")
            )
        ]
    )
    @DeleteMapping(path = ["/{ru}/{operationDate}/{trainIdentifier}"])
    fun deleteTrainIdentifier(@PathVariable("ru") @Size(min= 4, max = 4) ru: String, @PathVariable("operationDate") operationDate: LocalDate, @PathVariable("trainIdentifier") trainIdentifier: String) {
        println("$ru $operationDate $trainIdentifier")
    }

    @Operation(summary = "Get all train identifiers")
    @ApiResponse(responseCode = "200", description = "Train identifiers successfully retrieved")
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
    fun getAllTrainIdentifiers(): ResponseEntity<List<TrainIdentifierDto>> {
        return ResponseEntity.ok().build()
    }
}
