package ch.sbb.das.backend.trainjourneyplan;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationRepository;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.LocalDate;
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

    private final CompanyService companyService;

    public TrainIdentificationService(TrainIdentificationRepository trainIdentificationRepository, CompanyService companyService) {
        this.trainIdentificationRepository = trainIdentificationRepository;
        this.companyService = companyService;
    }

    public List<TrainIdentification> getNewTrainIdentificationsBetween(OffsetDateTime after, OffsetDateTime before) {
        List<TrainIdentificationEntity> trainRunEntities = trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before);
        return trainRunEntities.stream()
            .sorted(Comparator.comparing(TrainIdentificationEntity::getStartDateTime))
            .map(this::readEntity)
            .filter(tid -> !tid.companies().isEmpty())
            .toList();
    }

    public Set<CompanyCode> findCompanyCodesByStartDateAndTrainNumber(LocalDate startDate, String operationalTrainNumber) {
        OffsetDateTime startFrom = startDate.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();
        OffsetDateTime startTo = startDate.plusDays(1).atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();
        List<TrainIdentificationEntity> entities = trainIdentificationRepository
            .findAllByStartDateTimeBetweenAndOperationalTrainNumber(startFrom, startTo, operationalTrainNumber);
        return entities.stream()
            .map(TrainIdentificationEntity::getCompanies)
            .map(this::readCompanyCodes)
            .flatMap(Set::stream)
            .collect(Collectors.toSet());
    }

    private TrainIdentification readEntity(TrainIdentificationEntity trainRunEntity) {
        return new TrainIdentification(trainRunEntity.getId(), trainRunEntity.getOperationalTrainNumber(), trainRunEntity.getStartDateTime(),
            readCompanyCodes(trainRunEntity.getCompanies()));
    }

    private Set<CompanyCode> readCompanyCodes(String companies) {
        return Set.of(companies.split(",")).stream()
            .map(CompanyShortName::new)
            .map(companyService::findCompanyCodeByShortName)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .collect(Collectors.toSet());
    }

    public int savePreloadedTrainIds(Set<Integer> trainIdentificationIds) {
        if (trainIdentificationIds.isEmpty()) {
            return 0;
        }
        return trainIdentificationRepository.updatePreloadedAtByIds(DateTimeUtil.now(), trainIdentificationIds);
    }
}


