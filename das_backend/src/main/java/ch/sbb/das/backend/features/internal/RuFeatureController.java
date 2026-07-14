package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.*;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequiredArgsConstructor
@Tag(name = "RU features", description = "Admin API for managing RU feature toggles.")
public class RuFeatureController {

    private static final String PATH_SEGMENT_RU_FEATURES = "/ru-features";
    public static final String API_RU_FEATURES = ApiDocumentation.ADMIN_URI + PATH_SEGMENT_RU_FEATURES;
    static final String API_RU_FEATURES_ID = API_RU_FEATURES + "/{id}";

    private final RuFeatureServiceImpl ruFeatureService;

    @GetMapping(API_RU_FEATURES)
    @Operation(summary = "Get all RU features.", description = "Returns all RU feature toggles visible for the authorized companies.")
    @ApiResponse(responseCode = "200", description = "RU features found.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalRuFeatureResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllRuFeatures(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<InternalRuFeature> ruFeatures = ruFeatureService.getAllForAdmin();
        return ResponseEntityFactory.createOkResponse(new InternalRuFeatureResponse(ruFeatures), requestId);
    }

    @GetMapping(API_RU_FEATURES_ID)
    @Operation(summary = "Get RU feature by id.", description = "Returns a single RU feature toggle by its id.")
    @ApiResponse(responseCode = "200", description = "RU feature found.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalRuFeatureResponse.class)))
    @ApiResponse(responseCode = "404", description = "RU feature not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getRuFeatureById(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id) {
        Optional<InternalRuFeature> ruFeature = ruFeatureService.getById(id);
        if (ruFeature.isPresent()) {
            return ResponseEntityFactory.createOkResponse(new InternalRuFeatureResponse(ruFeature.get()), requestId);
        }
        return ResponseEntityFactory.createNotFoundResponse(requestId, null);
    }

    @PostMapping(API_RU_FEATURES)
    @Operation(summary = "Create a new RU feature.", description = "Creates a new RU feature toggle for a company.")
    @ApiResponse(responseCode = "201", description = "RU feature created.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalRuFeatureResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> createRuFeature(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid RuFeatureRequest createRequest) {
        InternalRuFeature ruFeature = ruFeatureService.create(createRequest);
        return ResponseEntityFactory.createCreatedResponse(new InternalRuFeatureResponse(ruFeature), requestId);
    }

    @PutMapping(API_RU_FEATURES_ID)
    @Operation(summary = "Update RU feature by id.", description = "Updates a single RU feature toggle by its id.")
    @ApiResponse(responseCode = "200", description = "RU feature updated.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalRuFeatureResponse.class)))
    @ApiResponse(responseCode = "404", description = "RU feature not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> updateRuFeature(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id,
        @RequestBody @Valid RuFeatureRequest updateRequest) {
        Optional<InternalRuFeature> ruFeature = ruFeatureService.update(id, updateRequest);
        if (ruFeature.isPresent()) {
            return ResponseEntityFactory.createOkResponse(new InternalRuFeatureResponse(ruFeature.get()), requestId);
        }
        return ResponseEntityFactory.createNotFoundResponse(requestId, null);
    }

    @DeleteMapping(API_RU_FEATURES_ID)
    @Operation(summary = "Delete RU feature by id.", description = "Deletes a single RU feature toggle by its id.")
    @ApiResponse(responseCode = "204", description = "RU feature deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteRuFeature(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id) {
        ruFeatureService.delete(id);
        return ResponseEntityFactory.createNoContentResponse(requestId);
    }

    @DeleteMapping(API_RU_FEATURES)
    @Operation(summary = "Delete RU features by ids.", description = "Deletes multiple RU feature toggles in a single request.")
    @ApiResponse(responseCode = "204", description = "RU features deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteRuFeaturesByIds(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid DeleteByIdsRequest deleteRequest) {
        ruFeatureService.deleteAllByIds(deleteRequest.ids());
        return ResponseEntityFactory.createNoContentResponse(requestId);
    }
}
