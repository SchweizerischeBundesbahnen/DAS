package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.ApiDocumentation;
import ch.sbb.backend.admin.application.settings.model.response.Logging;
import ch.sbb.backend.admin.application.settings.model.response.RuFeatureDto;
import ch.sbb.backend.admin.application.settings.model.response.SettingsResponse;
import ch.sbb.backend.admin.domain.settings.RuFeatureServiceImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@Tag(name = "Settings", description = "API for configuration settings.")
public class SettingsController {

    static final String PATH_SEGMENT_SETTINGS = "/settings";

    static final String API_SETTINGS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_SETTINGS;

    private final RuFeatureServiceImpl ruFeatureService;

    private final LoggingService loggingService;

    public SettingsController(RuFeatureServiceImpl ruFeatureService, LoggingService loggingService) {
        this.ruFeatureService = ruFeatureService;
        this.loggingService = loggingService;
    }

    @GetMapping(API_SETTINGS)
    @Operation(summary = "Fetch all configuration settings.")
    public SettingsResponse getConfigurations() {
        List<RuFeatureDto> allFeatures = ruFeatureService.getAll().stream()
                .map(RuFeatureDto::new)
                .toList();

        Logging logging = loggingService.getLogging();
        return new SettingsResponse(allFeatures, logging);

    }
}
