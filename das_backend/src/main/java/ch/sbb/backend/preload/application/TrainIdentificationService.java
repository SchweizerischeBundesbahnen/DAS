package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.CompanyCode;
import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.backend.preload.infrastructure.TrainIdentificationRepository;
import ch.sbb.backend.preload.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class TrainIdentificationService {

    private final TrainIdentificationRepository trainIdentificationRepository;

    private final UicCompanyCodeProvider uicCompanyCodeProvider;

    public TrainIdentificationService(TrainIdentificationRepository trainIdentificationRepository, UicCompanyCodeProvider uicCompanyCodeProvider) {
        this.trainIdentificationRepository = trainIdentificationRepository;
        this.uicCompanyCodeProvider = uicCompanyCodeProvider;
    }

    public List<TrainIdentification> processDailyTrainRunRequest(OffsetDateTime startDateTime) {
        // todo filter for preloaded_at and also older trains not yet preloaded

        List<TrainIdentificationEntity> trainRunEntities = trainIdentificationRepository.findAllByStartDateTimeBefore(startDateTime);

        return trainRunEntities.stream()
            .sorted(Comparator.comparing(TrainIdentificationEntity::getStartDateTime))
            .map(this::readEntity)
            .toList();
    }

    private TrainIdentification readEntity(TrainIdentificationEntity trainRunEntity) {
        return new TrainIdentification(trainRunEntity.getId(), trainRunEntity.getOperationalTrainNumber(), trainRunEntity.getStartDateTime().toLocalDate(),
            readCompanyCodes(trainRunEntity.getCompanies()));
    }

    private Set<CompanyCode> readCompanyCodes(String smsRus) {
        return Set.of(smsRus.split(",")).stream()
            .map(uicCompanyCodeProvider::getUicCompanyCode)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .collect(Collectors.toSet());
    }

    public int savePreloadedTrains(Set<TrainIdentification> trainIdentifications) {
        return trainIdentificationRepository.updatePreloadedAtByIds(OffsetDateTime.now(), trainIdentifications.stream().map(TrainIdentification::id).collect(Collectors.toSet()));
    }
}
