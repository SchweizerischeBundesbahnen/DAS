package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.OperationalTrainNumberFilter;
import ch.sbb.das.backend.indications.internal.model.RuIndicationEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatch;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatchesRequest;
import ch.sbb.das.backend.indications.internal.model.RuIndicationPeriod;
import ch.sbb.das.backend.indications.internal.model.ScheduleType;
import ch.sbb.das.backend.indications.internal.model.TrainNumberParity;
import ch.sbb.das.backend.locations.TafTapLocationReference;
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
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

@Service
@RequiredArgsConstructor
public class RuIndicationMatchServiceImpl {

    private static final List<String> DEFAULT_LANGUAGE_FALLBACK_ORDER = List.of("de", "fr", "it");
    private static final int SHADOW_TRAIN_NUMBER_OFFSET = 70_000;
    private static final int SHADOW_TRAIN_NUMBER_MAX = 96_000;

    private final RuIndicationRepository ruIndicationRepository;
    private final SpecialHolidayRepository specialHolidayRepository;

    private static boolean matchesCompany(Set<CompanyCode> companies, CompanyCode company) {
        return companies != null && companies.contains(company);
    }

    private static boolean matchesTrainNumber(List<OperationalTrainNumberFilter> operationalTrainNumberFilters, Integer trainNumber) {
        if (CollectionUtils.isEmpty(operationalTrainNumberFilters)) {
            return true;
        }

        return operationalTrainNumberFilters.stream()
            .anyMatch(filter -> matchesTrainNumberFilter(filter, resolveTrainNumberForMatching(trainNumber)));
    }

    private static Integer resolveTrainNumberForMatching(Integer operationalTrainNumber) {
        if (operationalTrainNumber > SHADOW_TRAIN_NUMBER_OFFSET && operationalTrainNumber < SHADOW_TRAIN_NUMBER_MAX) {
            return operationalTrainNumber - SHADOW_TRAIN_NUMBER_OFFSET;
        }
        return operationalTrainNumber;
    }

    private static boolean matchesTrainNumberFilter(OperationalTrainNumberFilter filter, Integer trainNumber) {
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

    private static List<TafTapLocationReference> findMatchingLocations(RuIndicationEntity ruIndication, Set<TafTapLocationReference> requestedLocations) {
        List<TafTapLocationReference> configuredLocations = ruIndication.getTafTapLocationReferences();
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

    private static RuIndicationEntry selectRuIndicationContent(RuIndicationEntity ruIndication, List<String> languagePreferenceOrder) {
        if (ruIndication == null) {
            return null;
        }

        for (String language : languagePreferenceOrder) {
            RuIndicationEntry selectedContent = switch (language) {
                case "de" -> RuIndicationEntry.normalize(new RuIndicationEntry(ruIndication.getTitleDe(), ruIndication.getTextDe()));
                case "fr" -> RuIndicationEntry.normalize(new RuIndicationEntry(ruIndication.getTitleFr(), ruIndication.getTextFr()));
                case "it" -> RuIndicationEntry.normalize(new RuIndicationEntry(ruIndication.getTitleIt(), ruIndication.getTextIt()));
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
            .filter(holiday -> holiday.getCompanies() != null && holiday.getCompanies().contains(company))
            .map(SpecialHolidayEntity::getScheduleType)
            .filter(scheduleType -> scheduleType == ScheduleType.MONDAY_SCHEDULE || scheduleType == ScheduleType.SUNDAY_SCHEDULE)
            .collect(Collectors.toSet());
    }

    public List<RuIndicationMatch> findMatches(RuIndicationMatchesRequest filterRequest, String acceptLanguage) {
        List<String> languagePreferenceOrder = resolveLanguagePreferenceOrder(acceptLanguage);
        Set<ScheduleType> holidayScheduleTypes = resolveHolidayScheduleTypes(filterRequest.company(), filterRequest.startDate());
        Map<TafTapLocationReference, List<RuIndicationEntry>> contentsByLocation = new LinkedHashMap<>();

        ruIndicationRepository.findAll().stream()
            .sorted(Comparator.comparing(RuIndicationEntity::getId))
            .filter(ruIndication -> matchesCompany(ruIndication.getCompanies(), filterRequest.company()))
            .filter(ruIndication -> matchesTrainNumber(ruIndication.getOperationalTrainNumberFilters(), filterRequest.operationalTrainNumber()))
            .filter(ruIndication -> matchesDate(ruIndication.getPeriods(), filterRequest.startDate(), holidayScheduleTypes))
            .forEach(ruIndication -> {
                RuIndicationEntry selectedContent = selectRuIndicationContent(ruIndication, languagePreferenceOrder);
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
