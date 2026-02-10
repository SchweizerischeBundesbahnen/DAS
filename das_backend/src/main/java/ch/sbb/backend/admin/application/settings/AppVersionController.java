package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.domain.settings.AppVersion;
import ch.sbb.backend.admin.domain.settings.AppVersionService;
import ch.sbb.backend.common.ApiDocumentation;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Settings", description = "API for configuration settings.")
public class AppVersionController {

    static final String PATH_SEGMENT_SETTINGS_APPVERSION = "/settings/app-version";

    static final String API_SETTINGS_APPVERSION = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_SETTINGS_APPVERSION;

    private final AppVersionService appVersionService;

    public AppVersionController(AppVersionService appVersionService) {
        this.appVersionService = appVersionService;
    }

    @GetMapping(API_SETTINGS_APPVERSION)
    @Operation(summary = "Get all versions.", description = "Returns a list of all versions stored in the database.")
    public List<AppVersion> getAll() {
        return appVersionService.getAll();
    }

}
