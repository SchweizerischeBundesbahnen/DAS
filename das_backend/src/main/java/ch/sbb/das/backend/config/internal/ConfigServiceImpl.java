package ch.sbb.das.backend.config.internal;

import ch.sbb.das.backend.config.ConfigService;
import ch.sbb.das.backend.config.Logging;
import ch.sbb.das.backend.config.Preload;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Service;

@Service
@EnableConfigurationProperties(PreloadBucketProperties.class)
public class ConfigServiceImpl implements ConfigService {

    @Value("${logging.url}")
    private String url;

    @Value("${logging.token}")
    private String token;

    private final PreloadBucketProperties preloadBucketProperties;

    ConfigServiceImpl(PreloadBucketProperties preloadBucketProperties) {
        this.preloadBucketProperties = preloadBucketProperties;
    }

    @Override
    public Logging getLogging() {
        return new Logging(url, token);
    }

    @Override
    public Preload getPreload() {
        PreloadBucketProperties.Credentials readOnly = preloadBucketProperties.readOnly();
        return new Preload(preloadBucketProperties.url(), readOnly.accessKeyId(), readOnly.secretAccessKey(), preloadBucketProperties.region());
    }
}
