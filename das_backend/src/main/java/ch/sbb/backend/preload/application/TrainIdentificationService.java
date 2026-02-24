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
        List<TrainIdentificationEntity> trainRunEntities = trainIdentificationRepository.findAllByStartDateTimeBefore(startDateTime);

        return trainRunEntities.stream()
            .sorted(Comparator.comparing(TrainIdentificationEntity::getStartDateTime))
            .map(this::readEntity)
            .toList();
    }

    private TrainIdentification readEntity(TrainIdentificationEntity trainRunEntity) {
        return TrainIdentification.builder()
            .operationalTrainNumber(trainRunEntity.getOperationalTrainNumber())
            .startDate(trainRunEntity.getStartDateTime().toLocalDate())
            .companies(readCompanyCodes(trainRunEntity.getCompanies()))
            .build();
    }

    private Set<CompanyCode> readCompanyCodes(String smsRus) {
        return Set.of(smsRus.split(",")).stream()
            .map(uicCompanyCodeProvider::getUicCompanyCode)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .collect(Collectors.toSet());
    }
}
