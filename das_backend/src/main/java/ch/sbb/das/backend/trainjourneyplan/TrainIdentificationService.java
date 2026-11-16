package ch.sbb.das.backend.trainjourneyplan;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.error.BadRequestException;
import ch.sbb.das.backend.common.error.NotFoundException;
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
import org.springframework.stereotype.Service;

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

    /**
     * @param after exclusive lower bound of the start time
     * @param before exclusive upper bound of the start time
     * @return all train identifications starting in between with at least one supported company, oldest start first; unsupported companies are dropped from each
     */
    public List<TrainIdentification> getTrainIdentificationsBetween(OffsetDateTime after, OffsetDateTime before) {
        List<TrainIdentificationEntity> trainRunEntities = trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBefore(after, before);
        Map<CompanyShortName, CompanyCode> codesByShortName = companyService.getAllCompanies().stream()
            .collect(Collectors.toMap(Company::shortName, Company::code));
        return trainRunEntities.stream()
            .sorted(Comparator.comparing(TrainIdentificationEntity::getStartDateTime))
            .map(entity -> readEntity(entity, codesByShortName))
            // exclude entries where none of the companies are supported
            .filter(tid -> !tid.companies().isEmpty())
            .toList();
    }

    /**
     * Resolves the companies running the given train number on the given start dates.
     *
     * @return the companies of the train identifications matching the given start dates and train number, sorted by start date then company; never empty
     * @throws BadRequestException when a start date is outside yesterday..tomorrow
     * @throws NotFoundException when no train identification departs within the candidate window on those dates
     */
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

        List<CompanyMatch> companyMatches = entities.stream()
            .flatMap(entity -> readCompanyCodes(entity.getCompanies()).stream()
                .map(companiesByCode::get)
                .filter(Objects::nonNull) // defensive: guards against timing mismatch between readCompanyCodes and getAllCompanies
                .map(company -> new CompanyMatch(company, startDateOf(entity))))
            .sorted(Comparator.comparing(CompanyMatch::startDate)
                .thenComparing(item -> item.company().shortName()))
            .toList();
        if (companyMatches.isEmpty()) {
            String sortedStartDates = startDates.stream().sorted().map(LocalDate::toString).collect(Collectors.joining(", "));
            throw new NotFoundException(
                "No train identification for train number " + operationalTrainNumber + " starting on " + sortedStartDates + " within the candidate window");
        }
        return companyMatches;
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
            throw new BadRequestException("startDate must be within " + earliest + " and " + latest + ", but got: " + outOfRange);
        }
    }

    /**
     * @param codesByShortName the supported companies, resolved once for the whole window instead of once per train
     */
    private static TrainIdentification readEntity(TrainIdentificationEntity trainRunEntity, Map<CompanyShortName, CompanyCode> codesByShortName) {
        Set<CompanyCode> companies = Set.of(trainRunEntity.getCompanies().split(",")).stream()
            .map(CompanyShortName::new)
            .map(codesByShortName::get)
            .filter(Objects::nonNull) // unsupported companies are silently dropped
            .collect(Collectors.toSet());
        return new TrainIdentification(trainRunEntity.getId(), trainRunEntity.getOperationalTrainNumber(), trainRunEntity.getStartDateTime(), companies);
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
}


