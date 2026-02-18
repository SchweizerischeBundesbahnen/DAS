package ch.sbb.backend.admin.application.settings;

import static ch.sbb.backend.admin.application.settings.SettingsController.PATH_SEGMENT_SETTINGS;

import ch.sbb.backend.admin.application.settings.model.request.AppVersionUpdateRequest;
import ch.sbb.backend.admin.application.settings.model.response.AppVersionResponse;
import ch.sbb.backend.admin.domain.settings.AppVersionService;
import ch.sbb.backend.admin.domain.settings.model.AppVersion;
import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.common.ApiErrorResponses;
import ch.sbb.backend.common.Response;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.apache.commons.lang3.NotImplementedException;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "AppVersions", description = "API for app versions.")
public class AppVersionController {

    static final String PATH_SEGMENT_SETTINGS_APPVERSION = PATH_SEGMENT_SETTINGS + "/app-version";

    static final String API_SETTINGS_APPVERSION = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_SETTINGS_APPVERSION;

    private final AppVersionService appVersionService;

    public AppVersionController(AppVersionService appVersionService) {
        this.appVersionService = appVersionService;
    }

    @GetMapping(API_SETTINGS_APPVERSION)
    @Operation(summary = "Get all versions.", description = "Returns a list of all versions stored in the database.")
    @ApiResponse(responseCode = "200", description = "Settings relevant for DAS-Client.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll() {
        List<AppVersion> versions = appVersionService.getAll();
        return ResponseEntity.ok(new AppVersionResponse(versions));
    }

    @GetMapping(API_SETTINGS_APPVERSION + "/{id}")
    @Operation(summary = "Get app version by id.", description = "Returns a single app version by its id.")
    @ApiResponse(responseCode = "200", description = "App version found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionResponse.class)))
    @ApiResponse(responseCode = "404", description = "App version not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getOne(@PathVariable Integer id) {
        AppVersion version = appVersionService.getOne(id);
        if (version == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(new AppVersionResponse(List.of(version)));
    }

    public ResponseEntity<? extends Response> create(Integer id) {
        //        TODO implement
        throw new NotImplementedException();
    }

    @PutMapping(API_SETTINGS_APPVERSION + "/{id}")
    @Operation(summary = "Update app version by id.", description = "Updates a single app version by its id.")
    @ApiResponse(responseCode = "200", description = "App version updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = AppVersionResponse.class)))
    @ApiResponse(responseCode = "404", description = "App version not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> update(@PathVariable Integer id, @RequestBody AppVersionUpdateRequest updateRequest) {
        AppVersion updatedVersion = appVersionService.update(id, updateRequest);
        if (updatedVersion == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(new AppVersionResponse(List.of(updatedVersion)));
    }

    public ResponseEntity<? extends Response> delete(Integer id) {
        //        TODO implement
        throw new NotImplementedException();
    }

}
