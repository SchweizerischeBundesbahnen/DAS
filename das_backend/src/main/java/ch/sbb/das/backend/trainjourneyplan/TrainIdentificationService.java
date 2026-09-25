package ch.sbb.das.backend.trainjourneyplan;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.CompanyMatch;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationRepository;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class TrainIdentificationService {

    private final TrainIdentificationRepository trainIdentificationRepository;
    private final CompanyService companyService;

    /**
     * A train journey is only available at TMS-VAD within this many hours around departure (shared with the preloader via {@code trainjourneypreloader.hours-before-departure}). Candidates whose
     * departure is outside the {@code now +/- hoursBeforeDeparture} window cannot be called and are excluded from the search-without-RU results.
     */
    @Value("${trainjourneypreloader.hours-before-departure}")
    private int hoursBeforeDeparture;

    public List<TrainIdentification> getNewTrainIdentificationsBetween(OffsetDateTime after, OffsetDateTime before) {
        List<TrainIdentificationEntity> trainRunEntities = trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before);
        return trainRunEntities.stream()
            .sorted(Comparator.comparing(TrainIdentificationEntity::getStartDateTime))
            .map(this::readEntity)
            // exclude entries where none of the companies are supported
            .filter(tid -> !tid.companies().isEmpty())
            .toList();
    }

    public List<CompanyMatch> findCompaniesByStartDatesAndTrainNumber(Set<LocalDate> startDates, String operationalTrainNumber) {
        validateStartDates(startDates);
        OffsetDateTime earliestStartDateTime = startDates.stream().min(Comparator.naturalOrder())
            .orElseThrow()
            .atStartOfDay(DateTimeUtil.SWISS_ZONE)
            .toOffsetDateTime();
        OffsetDateTime latestStartDateTime = DateTimeUtil.now().plusHours(hoursBeforeDeparture);

        List<TrainIdentificationEntity> entities = trainIdentificationRepository
            .findAllByStartDateTimeRangeAndOperationalTrainNumber(earliestStartDateTime, latestStartDateTime, operationalTrainNumber).stream()
            // narrow to the exact requested dates in case the request had gaps
            .filter(entity -> startDates.contains(startDateOf(entity)))
            .toList();

        Map<CompanyCode, Company> companiesByCode = companyService.getAllCompanies().stream()
            .collect(Collectors.toMap(Company::code, company -> company));

        return entities.stream()
            .flatMap(entity -> readCompanyCodes(entity.getCompanies()).stream()
                .map(companiesByCode::get)
                .filter(Objects::nonNull) // defensive: guards against timing mismatch between readCompanyCodes and getAllCompanies
                .map(company -> new CompanyMatch(company, startDateOf(entity))))
            .sorted(Comparator.comparing(CompanyMatch::startDate)
                .thenComparing(item -> item.company().shortName()))
            .toList();
    }

    private static LocalDate startDateOf(TrainIdentificationEntity entity) {
        return entity.getStartDateTime().atZoneSameInstant(DateTimeUtil.SWISS_ZONE).toLocalDate();
    }

    private void validateStartDates(Set<LocalDate> startDates) {
        LocalDate today = DateTimeUtil.today();
        LocalDate earliest = today.minusDays(1);
        LocalDate latest = today.plusDays(1);

        List<LocalDate> outOfRange = startDates.stream()
            .filter(startDate -> startDate.isBefore(earliest) || startDate.isAfter(latest))
            .toList();

        if (!outOfRange.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                "startDate must be within " + earliest + " and " + latest + ", but got: " + outOfRange);
        }
    }

    private TrainIdentification readEntity(TrainIdentificationEntity trainRunEntity) {
        return new TrainIdentification(trainRunEntity.getId(), trainRunEntity.getOperationalTrainNumber(), trainRunEntity.getStartDateTime(),
            readCompanyCodes(trainRunEntity.getCompanies()));
    }

    /**
     * Resolves company short names to {@link CompanyCode}s, retaining only those registered in {@link CompanyService}. Unsupported companies are silently dropped.
     */
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


