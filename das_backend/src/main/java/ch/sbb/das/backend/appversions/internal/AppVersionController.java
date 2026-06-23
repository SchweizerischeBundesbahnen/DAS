package ch.sbb.das.backend.appversions.internal;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "AppVersions", description = "API for app versions.")
@PreAuthorize("@companyAuthorizer.isAdminTenant")
public class AppVersionController {

    static final String PATH_SEGMENT_APP_VERSIONS = "/app-versions";
    public static final String API_APP_VERSIONS = ApiDocumentation.DRIVER_URI + PATH_SEGMENT_APP_VERSIONS;
    static final String API_APP_VERSIONS_ID = API_APP_VERSIONS + "/{id}";

    private final AppVersionServiceImpl appVersionServiceImpl;

    public AppVersionController(AppVersionServiceImpl appVersionServiceImpl) {
        this.appVersionServiceImpl = appVersionServiceImpl;
    }

    @GetMapping(API_APP_VERSIONS)
    @Operation(summary = "Get all versions.", description = "Returns relevant usage status of App versions deployed.")
    @ApiResponse(responseCode = "200", description = "App versions resp. its managed state.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionsResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllAppVersions(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<AppVersion> versions = appVersionServiceImpl.getAll();
        return ResponseEntityFactory.createOkResponse(new AppVersionsResponse(versions), requestId);
    }

    @GetMapping(API_APP_VERSIONS_ID)
    @Operation(summary = "Get app version by id.", description = "Returns a single app version by its id.")
    @ApiResponse(responseCode = "200", description = "App version found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionsResponse.class)))
    @ApiResponse(responseCode = "404", description = "App version not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAppVersionById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        AppVersion version = appVersionServiceImpl.getById(id);
        if (version == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new AppVersionsResponse(version), requestId);
    }

    @PostMapping(API_APP_VERSIONS)
    @Operation(summary = "Create new app version.", description = "Creates a new app version entry.")
    @ApiResponse(responseCode = "201", description = "App version created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionsResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<AppVersionsResponse> createAppVersion(@RequestBody @Valid AppVersionRequest createRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        AppVersion createdVersion = appVersionServiceImpl.create(createRequest);
        return ResponseEntityFactory.createCreatedResponse(new AppVersionsResponse(List.of(createdVersion)), requestId);
    }

    @PutMapping(API_APP_VERSIONS_ID)
    @Operation(summary = "Update app version by id.", description = "Updates a single app version by its id.")
    @ApiResponse(responseCode = "200", description = "App version updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionsResponse.class)))
    @ApiResponse(responseCode = "404", description = "App version not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> updateAppVersion(@PathVariable Integer id, @RequestBody @Valid AppVersionRequest updateRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        AppVersion updatedVersion = appVersionServiceImpl.update(id, updateRequest);
        if (updatedVersion == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new AppVersionsResponse(List.of(updatedVersion)), requestId);
    }

    @DeleteMapping(API_APP_VERSIONS_ID)
    @Operation(summary = "Delete app version by id.", description = "Delete a single app version by its id.")
    @ApiResponse(responseCode = "204", description = "App version deleted.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> deleteAppVersionById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        appVersionServiceImpl.delete(id);
        return ResponseEntity.noContent().build();
    }
}
