package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.backend.admin.application.settings.model.response.Logging;
import ch.sbb.backend.admin.application.settings.model.response.Preload;
import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ConfigService {

    @Value("${logging.url}")
    private String url;

    @Value("${logging.token}")
    private String token;

    @Value("${preload.bucket.bucketUrl}")
    private String bucketUrl;

    @Value("${preload.bucket.accessKey}")
    private String accessKey;

    @Value("${preload.bucket.accessSecret}")
    private String accessSecret;

    @Value("")
    private Boolean updateRequired;

    @Value("")
    private LocalDate expiryDate;

    @Value("")
    private String currentVersion;

    public Logging getLogging() {
        return new Logging(url, token);
    }

    public Preload getPreload() {
        return new Preload(bucketUrl, accessKey, accessSecret);
    }

    public AppVersion getAppVersion() {
        return new AppVersion(updateRequired, expiryDate, currentVersion);
    }
}
