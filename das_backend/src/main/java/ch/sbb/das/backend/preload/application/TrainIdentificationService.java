package ch.sbb.das.backend.preload.application;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyShortName;
import ch.sbb.das.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.das.backend.preload.infrastructure.TrainIdentificationRepository;
import ch.sbb.das.backend.preload.infrastructure.model.entities.TrainIdentificationEntity;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyCodeRepository;
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

    private final CompanyCodeRepository companyCodeRepository;

    public TrainIdentificationService(TrainIdentificationRepository trainIdentificationRepository, CompanyCodeRepository companyCodeRepository) {
        this.trainIdentificationRepository = trainIdentificationRepository;
        this.companyCodeRepository = companyCodeRepository;
    }

    public List<TrainIdentification> getNewTrainIdentificationsBetween(OffsetDateTime after, OffsetDateTime before) {
        List<TrainIdentificationEntity> trainRunEntities = trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before);
        return trainRunEntities.stream()
            .sorted(Comparator.comparing(TrainIdentificationEntity::getStartDateTime))
            .map(this::readEntity)
            .filter(tid -> !tid.companies().isEmpty())
            .toList();
    }

    private TrainIdentification readEntity(TrainIdentificationEntity trainRunEntity) {
        return new TrainIdentification(trainRunEntity.getId(), trainRunEntity.getOperationalTrainNumber(), trainRunEntity.getStartDateTime(),
            readCompanyCodes(trainRunEntity.getCompanies()));
    }

    private Set<CompanyCode> readCompanyCodes(String smsRus) {
        return Set.of(smsRus.split(",")).stream()
            .map(CompanyShortName::of)
            .map(companyCodeRepository::findCompanyCode)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .collect(Collectors.toSet());
    }

    public int savePreloadedTrains(Set<TrainIdentification> trainIdentifications) {
        return trainIdentificationRepository.updatePreloadedAtByIds(OffsetDateTime.now(), trainIdentifications.stream().map(TrainIdentification::id).collect(Collectors.toSet()));
    }
}
