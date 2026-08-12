package ch.sbb.das.backend.cargo.infrastructure;

import java.time.LocalDate;

public interface TransportPaperClient {

    String getDownloadUrl(
        String trainPathId,
        LocalDate operatingDay,
        String countryCodeIso,
        Integer locationPrimaryCode,
        Integer passIndex
    );
}
