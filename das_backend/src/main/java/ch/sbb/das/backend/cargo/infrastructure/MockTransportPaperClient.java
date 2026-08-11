package ch.sbb.das.backend.cargo.infrastructure;

import java.time.LocalDate;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

// todo: delete as soon as orca is ready
@Slf4j
@Component
@ConditionalOnProperty(name = "formation.transport-paper.mock.enabled", havingValue = "true")
public class MockTransportPaperClient implements TransportPaperClient {

    private final String fixedDownloadUrl;

    public MockTransportPaperClient(@Value("${formation.transport-paper.mock.download-url}") String fixedDownloadUrl) {
        this.fixedDownloadUrl = fixedDownloadUrl;
        log.info("Using mock transport paper client");
    }

    @Override
    public String getDownloadUrl(
        String trainPathId,
        LocalDate operatingDay,
        String countryCodeIso,
        Integer locationPrimaryCode,
        Integer passIndex
    ) {
        return fixedDownloadUrl;
    }
}
