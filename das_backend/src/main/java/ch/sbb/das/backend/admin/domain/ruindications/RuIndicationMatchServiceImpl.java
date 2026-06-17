package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationContent;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationEntry;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatch;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatchesRequest;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationPeriod;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationScope;
import ch.sbb.das.backend.admin.application.ruindications.model.ScheduleType;
import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.ruindications.model.TrainNumberFilterRequest;
import ch.sbb.das.backend.admin.application.ruindications.model.TrainNumberParity;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import org.springframework.util.CollectionUtils;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class RuIndicationMatchServiceImpl implements RuIndicationMatchService {

    private static final List<String> DEFAULT_LANGUAGE_FALLBACK_ORDER = List.of("de", "fr", "it");
    private static final int SHADOW_TRAIN_NUMBER_OFFSET = 70_000;
    private static final int SHADOW_TRAIN_NUMBER_MAX = 96_000;

    private final RuIndicationRepository ruIndicationRepository;
    private final SpecialHolidayRepository specialHolidayRepository;

    public RuIndicationMatchServiceImpl(RuIndicationRepository ruIndicationRepository, SpecialHolidayRepository specialHolidayRepository) {
        this.ruIndicationRepository = ruIndicationRepository;
        this.specialHolidayRepository = specialHolidayRepository;
    }

    private static boolean matchesCompany(RuIndicationScope scope, CompanyCode company) {
        return scope != null && scope.companies() != null && scope.companies().contains(company);
    }

    private static boolean matchesTrainNumber(RuIndicationScope scope, Integer trainNumber) {
        if (scope == null || CollectionUtils.isEmpty(scope.operationalTrainNumberFilters())) {
            return true;
        }

        return scope.operationalTrainNumberFilters().stream()
            .anyMatch(filter -> matchesTrainNumberFilter(filter, resolveTrainNumberForMatching(trainNumber)));
    }

    private static Integer resolveTrainNumberForMatching(Integer operationalTrainNumber) {
        if (operationalTrainNumber > SHADOW_TRAIN_NUMBER_OFFSET && operationalTrainNumber < SHADOW_TRAIN_NUMBER_MAX) {
            return operationalTrainNumber - SHADOW_TRAIN_NUMBER_OFFSET;
        }
        return operationalTrainNumber;
    }

    private static boolean matchesTrainNumberFilter(TrainNumberFilterRequest filter, Integer trainNumber) {
        if (filter == null || filter.expression() == null || trainNumber == null) {
            return false;
        }
        if (!matchesParity(trainNumber, filter.parity())) {
            return false;
        }

        String expression = filter.expression();
        if (!expression.contains("-")) {
            return trainNumber == Integer.parseInt(expression);
        }

        String[] parts = expression.split("-", 2);
        int from = Integer.parseInt(parts[0]);
        int to = Integer.parseInt(parts[1]);
        return trainNumber >= from && trainNumber <= to;
    }

    private static boolean matchesParity(Integer trainNumber, TrainNumberParity parity) {
        return switch (parity) {
            case ANY -> true;
            case EVEN -> trainNumber % 2 == 0;
            case ODD -> trainNumber % 2 != 0;
        };
    }

    private static boolean matchesDate(List<RuIndicationPeriod> periods, LocalDate scheduleDate, Set<ScheduleType> holidayScheduleTypes) {
        if (scheduleDate == null || CollectionUtils.isEmpty(periods)) {
            return true;
        }

        return periods.stream().anyMatch(period -> isDateInPeriod(period, scheduleDate, holidayScheduleTypes));
    }

    private static boolean isDateInPeriod(RuIndicationPeriod period, LocalDate scheduleDate, Set<ScheduleType> holidayScheduleTypes) {
        if (period == null) {
            return false;
        }

        if (scheduleDate.isBefore(period.validFrom()) || scheduleDate.isAfter(period.validTo())) {
            return false;
        }

        if (period.validFrom().isEqual(period.validTo())) {
            return true;
        }

        if (CollectionUtils.isEmpty(period.weekdays())) {
            return true;
        }

        if (period.weekdays().contains(scheduleDate.getDayOfWeek())) {
            return true;
        }

        Set<DayOfWeek> effectiveWeekdays = EnumSet.noneOf(DayOfWeek.class);
        for (ScheduleType scheduleType : holidayScheduleTypes) {
            if (scheduleType == ScheduleType.MONDAY_SCHEDULE) {
                effectiveWeekdays.add(DayOfWeek.MONDAY);
            } else if (scheduleType == ScheduleType.SUNDAY_SCHEDULE) {
                effectiveWeekdays.add(DayOfWeek.SUNDAY);
            }
        }
        return period.weekdays().stream().anyMatch(effectiveWeekdays::contains);
    }

    private static List<TafTapLocationReference> findMatchingLocations(RuIndication ruIndication, Set<TafTapLocationReference> requestedLocations) {
        Set<TafTapLocationReference> configuredLocations = ruIndication.scope() == null ? null : ruIndication.scope().tafTapLocationReferences();
        if (CollectionUtils.isEmpty(configuredLocations) || CollectionUtils.isEmpty(requestedLocations)) {
            return List.of();
        }

        return requestedLocations.stream()
            .filter(configuredLocations::contains)
            .sorted(Comparator.comparing(TafTapLocationReference::toLocationCode))
            .toList();
    }

    private static List<String> resolveLanguagePreferenceOrder(String acceptLanguage) {
        Set<String> resolvedLanguages = new LinkedHashSet<>();
        if (acceptLanguage != null && !acceptLanguage.isBlank()) {
            String requestedLanguage = normalizeLanguage(acceptLanguage);
            if (requestedLanguage != null && DEFAULT_LANGUAGE_FALLBACK_ORDER.contains(requestedLanguage)) {
                resolvedLanguages.add(requestedLanguage);
            }
        }

        resolvedLanguages.addAll(DEFAULT_LANGUAGE_FALLBACK_ORDER);
        return List.copyOf(resolvedLanguages);
    }

    private static String normalizeLanguage(String language) {
        if (language == null || language.isBlank()) {
            return null;
        }

        // Be tolerant with RFC7231 style headers (e.g. "fr-CH,fr;q=0.9").
        String firstLanguageRange = language.split(",", 2)[0].trim();
        String languageWithoutParams = firstLanguageRange.split(";", 2)[0].trim();
        if (languageWithoutParams.isBlank() || "*".equals(languageWithoutParams)) {
            return null;
        }

        return languageWithoutParams.toLowerCase().substring(0, 2);
    }

    private static RuIndicationEntry selectRuIndicationContent(RuIndicationContent ruIndicationContent, List<String> languagePreferenceOrder) {
        if (ruIndicationContent == null) {
            return null;
        }

        for (String language : languagePreferenceOrder) {
            RuIndicationEntry selectedContent = switch (language) {
                case "de" -> ruIndicationContent.de();
                case "fr" -> ruIndicationContent.fr();
                case "it" -> ruIndicationContent.it();
                default -> null;
            };
            if (selectedContent != null) {
                return selectedContent;
            }
        }

        return null;
    }

    private Set<ScheduleType> resolveHolidayScheduleTypes(CompanyCode company, LocalDate scheduleDate) {
        if (company == null || scheduleDate == null) {
            return Set.of();
        }

        return specialHolidayRepository.findAllByDate(scheduleDate).stream()
            .filter(holiday -> holiday.companies() != null && holiday.companies().contains(company))
            .map(SpecialHoliday::scheduleType)
            .filter(scheduleType -> scheduleType == ScheduleType.MONDAY_SCHEDULE || scheduleType == ScheduleType.SUNDAY_SCHEDULE)
            .collect(Collectors.toSet());
    }

    @Override
    public List<RuIndicationMatch> findMatches(RuIndicationMatchesRequest filterRequest, String acceptLanguage) {
        List<String> languagePreferenceOrder = resolveLanguagePreferenceOrder(acceptLanguage);
        Set<ScheduleType> holidayScheduleTypes = resolveHolidayScheduleTypes(filterRequest.company(), filterRequest.startDate());
        Map<TafTapLocationReference, List<RuIndicationEntry>> contentsByLocation = new LinkedHashMap<>();

        ruIndicationRepository.findAll().stream()
            .sorted(Comparator.comparing(RuIndication::id))
            .filter(ruIndication -> matchesCompany(ruIndication.scope(), filterRequest.company()))
            .filter(ruIndication -> matchesTrainNumber(ruIndication.scope(), filterRequest.operationalTrainNumber()))
            .filter(ruIndication -> matchesDate(ruIndication.periods(), filterRequest.startDate(), holidayScheduleTypes))
            .forEach(ruIndication -> {
                RuIndicationEntry selectedContent = selectRuIndicationContent(ruIndication.content(), languagePreferenceOrder);
                if (selectedContent == null) {
                    return;
                }

                findMatchingLocations(ruIndication, filterRequest.tafTapLocationReferences()).forEach(location ->
                    contentsByLocation.computeIfAbsent(location, ignored -> new ArrayList<>()).add(selectedContent));
            });

        return contentsByLocation.entrySet().stream()
            .sorted(Map.Entry.comparingByKey(Comparator.comparing(TafTapLocationReference::toLocationCode)))
            .map(entry -> new RuIndicationMatch(entry.getKey(), List.copyOf(entry.getValue())))
            .toList();
    }
}
