package ch.sbb.backend.admin.application.settings;

import static ch.sbb.backend.admin.application.settings.SettingsController.PATH_SEGMENT_SETTINGS;

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

    public ResponseEntity<? extends Response> getOne(Integer id) {
        //        TODO implement
        throw new NotImplementedException();
    }

    public ResponseEntity<? extends Response> update(Integer id) {
        //        TODO implement
        throw new NotImplementedException();
    }

    public ResponseEntity<? extends Response> create(Integer id) {
        //        TODO implement
        throw new NotImplementedException();
    }

    public ResponseEntity<? extends Response> delete(Integer id) {
        //        TODO implement
        throw new NotImplementedException();
    }

}
