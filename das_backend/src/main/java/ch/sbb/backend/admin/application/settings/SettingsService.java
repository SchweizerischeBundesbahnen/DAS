package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SettingsService {

    @Value("")
    private Boolean updateRequired;

    @Value("")
    private LocalDate expiryDate;

    @Value("")
    private String currentVersion;

    public CurrentAppVersion getAppVersion() {
        return new CurrentAppVersion(updateRequired, expiryDate, currentVersion);
    }
}
