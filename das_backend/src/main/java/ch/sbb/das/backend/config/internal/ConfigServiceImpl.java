package ch.sbb.das.backend.config.internal;

import ch.sbb.das.backend.config.ConfigService;
import ch.sbb.das.backend.config.Logging;
import ch.sbb.das.backend.config.Preload;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ConfigServiceImpl implements ConfigService {

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

    @Override
    public Logging getLogging() {
        return new Logging(url, token);
    }

    @Override
    public Preload getPreload() {
        return new Preload(bucketUrl, accessKey, accessSecret);
    }
}
