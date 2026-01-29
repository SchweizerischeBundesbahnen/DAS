package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.application.settings.model.response.Logging;
import ch.sbb.backend.admin.application.settings.model.response.Preload;
import ch.sbb.backend.admin.application.settings.model.response.RuFeature;
import ch.sbb.backend.admin.application.settings.model.response.Settings;
import ch.sbb.backend.admin.application.settings.model.response.SettingsResponse;
import ch.sbb.backend.admin.domain.settings.RuFeatureService;
import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.common.ApiParametersDefault;
import ch.sbb.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.backend.common.ResponseEntityFactory;
import ch.sbb.backend.common.ApiErrorResponses;
import ch.sbb.backend.common.Response;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Settings", description = "API for configuration settings.")
public class SettingsController {

    static final String PATH_SEGMENT_SETTINGS = "/settings";

    static final String API_SETTINGS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_SETTINGS;

    private final RuFeatureService ruFeatureService;

    private final ConfigService configService;

    public SettingsController(RuFeatureService ruFeatureService, ConfigService configService) {
        this.ruFeatureService = ruFeatureService;
        this.configService = configService;
    }

    @GetMapping(API_SETTINGS)
    @Operation(summary = "Fetch all configuration settings.")
    @ApiResponse(responseCode = "200", description = "Settings relevant for DAS-Client.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SettingsResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getSettings(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId
    ) {
        List<RuFeature> allFeatures = ruFeatureService.getAll().stream()
            .map(RuFeature::new)
            .toList();

        Logging logging = configService.getLogging();
        Preload preload = configService.getPreload();

        return ResponseEntityFactory.createOkResponse(new SettingsResponse(List.of(new Settings(allFeatures, logging, preload))),
            null,
            requestId);
    }
}
