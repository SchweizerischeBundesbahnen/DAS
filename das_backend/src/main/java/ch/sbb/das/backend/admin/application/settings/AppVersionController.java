package ch.sbb.das.backend.admin.application.settings;

import static ch.sbb.das.backend.admin.application.settings.SettingsController.PATH_SEGMENT_SETTINGS;

import ch.sbb.das.backend.admin.application.settings.model.request.AppVersionRequest;
import ch.sbb.das.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.das.backend.admin.application.settings.model.response.AppVersionResponse;
import ch.sbb.das.backend.admin.application.settings.model.response.AppVersionsResponse;
import ch.sbb.das.backend.admin.domain.settings.AppVersionService;
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
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
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
@PreAuthorize("@companyAuthorizer.isAdminTenant(authentication)")
public class AppVersionController {

    static final String PATH_SEGMENT_SETTINGS_APP_VERSION = PATH_SEGMENT_SETTINGS + "/app-version";
    public static final String API_SETTINGS_APP_VERSION = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_SETTINGS_APP_VERSION;
    static final String API_SETTINGS_APP_VERSION_ID = API_SETTINGS_APP_VERSION + "/{id}";

    private final AppVersionService appVersionService;

    public AppVersionController(AppVersionService appVersionService) {
        this.appVersionService = appVersionService;
    }

    @GetMapping(API_SETTINGS_APP_VERSION)
    @Operation(summary = "Get all versions.", description = "Returns relevant usage status of App versions deployed.")
    @ApiResponse(responseCode = "200", description = "App versions resp. its managed state.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionsResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<AppVersion> versions = appVersionService.getAll();
        return ResponseEntityFactory.createOkResponse(new AppVersionsResponse(versions), null, requestId);
    }

    @GetMapping(API_SETTINGS_APP_VERSION_ID)
    @Operation(summary = "Get app version by id.", description = "Returns a single app version by its id.")
    @ApiResponse(responseCode = "200", description = "App version found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionResponse.class)))
    @ApiResponse(responseCode = "404", description = "App version not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        AppVersion version = appVersionService.getById(id);
        if (version == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new AppVersionResponse(version), null, requestId);
    }

    @PostMapping(API_SETTINGS_APP_VERSION)
    @Operation(summary = "Create new app version.", description = "Creates a new app version entry.")
    @ApiResponse(responseCode = "201", description = "App version created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<AppVersionResponse> create(@RequestBody @Valid AppVersionRequest createRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        AppVersion createdVersion = appVersionService.create(createRequest);
        HttpHeaders headers = ResponseEntityFactory.createOkHeaders(requestId);
        return new ResponseEntity<>(new AppVersionResponse(List.of(createdVersion)), headers, HttpStatus.CREATED);
    }

    @PutMapping(API_SETTINGS_APP_VERSION_ID)
    @Operation(summary = "Update app version by id.", description = "Updates a single app version by its id.")
    @ApiResponse(responseCode = "200", description = "App version updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionResponse.class)))
    @ApiResponse(responseCode = "404", description = "App version not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> update(@PathVariable Integer id, @RequestBody @Valid AppVersionRequest updateRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        AppVersion updatedVersion = appVersionService.update(id, updateRequest);
        if (updatedVersion == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new AppVersionResponse(List.of(updatedVersion)), null, requestId);
    }

    @DeleteMapping(API_SETTINGS_APP_VERSION_ID)
    @Operation(summary = "Delete app version by id.", description = "Delete a single app version by its id.")
    @ApiResponse(responseCode = "204", description = "App version deleted.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> delete(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        appVersionService.delete(id);
        return ResponseEntity.noContent().build();
    }

}
