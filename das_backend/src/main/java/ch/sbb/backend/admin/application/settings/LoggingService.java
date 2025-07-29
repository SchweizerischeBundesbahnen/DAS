package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.application.settings.model.response.Logging;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class LoggingService {

    @Value("${logging.url}")
    private String url;

    @Value("${logging.token}")
    private String token;

    public Logging getLogging () {
        return new Logging(url, token);
    }

}
