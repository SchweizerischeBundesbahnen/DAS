package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.CompanyCode;
import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * @deprecated todo train number api (#535)
 */
@Deprecated
@Service
public class MockTrainIdentificationService {

    private static final List<String> SFERA_MOCK_TRAIN_NUMBERS = List.of("1513", "1670", "1671", "1672", "1809", "2266", "7318", "15154", "19240", "T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9",
        "T10", "T11", "T12", "T13", "T14", "T15", "T16", "T17", "T18", "T20", "T21", "T22", "T23", "T24", "T25", "T27", "T28", "T9999");

    @Value("${sfera.company-code}")
    private String companyCode;

    public List<TrainIdentification> getNewTrainIdentifications(OffsetDateTime since) {
        AtomicInteger i = new AtomicInteger();
        return SFERA_MOCK_TRAIN_NUMBERS.stream().map(trainNumber -> new TrainIdentification(i.getAndIncrement(), trainNumber, since.toLocalDate(), Set.of(CompanyCode.of(companyCode))))
            .toList();
    }

    public void savePreloadedTrains(Set<TrainIdentification> trainIdentifications) {
        // mock..
    }
}
