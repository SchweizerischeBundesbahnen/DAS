package ch.sbb.das.backend.driversettings.internal;

import static ch.sbb.das.backend.appversions.internal.SemanticVersion.SEM_VERSION_PATTERN;

import ch.sbb.das.backend.appversions.AppVersionService;
import ch.sbb.das.backend.appversions.CurrentAppVersion;
import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.config.ConfigService;
import ch.sbb.das.backend.config.Logging;
import ch.sbb.das.backend.config.Preload;
import ch.sbb.das.backend.feature.RuFeature;
import ch.sbb.das.backend.feature.RuFeatureService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Pattern;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "Settings", description = "API for configuration settings.")
public class SettingsController {

    static final String PATH_SEGMENT_SETTINGS = "/settings";

    public static final String API_SETTINGS = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_SETTINGS;

    private final RuFeatureService ruFeatureService;

    private final ConfigService configService;
    private final AppVersionService appVersionService;

    @GetMapping(API_SETTINGS)
    @Operation(summary = "Fetch all configuration settings.")
    @ApiResponse(responseCode = "200", description = "Settings relevant for DAS-Client.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SettingsResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getSettings(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestHeader(value = "X-App-Version") @Pattern(regexp = SEM_VERSION_PATTERN) String xAppVersion
    ) {
        List<RuFeature> allFeatures = ruFeatureService.getAll().stream()
            .toList();

        Logging logging = configService.getLogging();
        Preload preload = configService.getPreload();
        CurrentAppVersion currentAppVersion = appVersionService.getCurrent(xAppVersion);

        return ResponseEntityFactory.createOkResponse(new SettingsResponse(List.of(new Settings(allFeatures, logging, preload, currentAppVersion))),
            requestId);
    }
}
