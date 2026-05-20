package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatch;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatchesRequest;
import ch.sbb.das.backend.admin.application.notices.model.NoticePeriod;
import ch.sbb.das.backend.admin.application.notices.model.NoticeScope;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateContent;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTrainNumberFilterRequest;
import ch.sbb.das.backend.admin.application.notices.model.ScheduleType;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.notices.model.TrainNumberParity;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
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

public class NoticeMatchServiceImpl implements NoticeMatchService {

    private static final List<String> DEFAULT_LANGUAGE_FALLBACK_ORDER = List.of("de", "fr", "it");
    private static final int SHADOW_TRAIN_NUMBER_OFFSET = 70_000;

    private final NoticeRepository noticeRepository;
    private final SpecialHolidayRepository specialHolidayRepository;

    public NoticeMatchServiceImpl(NoticeRepository noticeRepository, SpecialHolidayRepository specialHolidayRepository) {
        this.noticeRepository = noticeRepository;
        this.specialHolidayRepository = specialHolidayRepository;
    }

    private static boolean matchesCompany(NoticeScope scope, CompanyCode company) {
        return scope != null && scope.companies() != null && scope.companies().contains(company);
    }

    private static boolean matchesTrainNumber(NoticeScope scope, Integer trainNumber) {
        if (scope == null || scope.operationalTrainNumberFilters() == null || scope.operationalTrainNumberFilters().isEmpty()) {
            return true;
        }

        return scope.operationalTrainNumberFilters().stream()
            .anyMatch(filter -> matchesTrainNumberFilter(filter, resolveTrainNumberForMatching(trainNumber)));
    }

    private static Integer resolveTrainNumberForMatching(Integer operationalTrainNumber) {
        if (operationalTrainNumber > SHADOW_TRAIN_NUMBER_OFFSET && operationalTrainNumber < SHADOW_TRAIN_NUMBER_OFFSET + 1000) {
            return operationalTrainNumber - SHADOW_TRAIN_NUMBER_OFFSET;
        }
        return operationalTrainNumber;
    }

    private static boolean matchesTrainNumberFilter(NoticeTrainNumberFilterRequest filter, Integer trainNumber) {
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

    private static boolean matchesDate(List<NoticePeriod> periods, LocalDate scheduleDate, Set<ScheduleType> holidayScheduleTypes) {
        if (scheduleDate == null || periods == null || periods.isEmpty()) {
            return true;
        }

        return periods.stream().anyMatch(period -> isDateInPeriod(period, scheduleDate, holidayScheduleTypes));
    }

    private static boolean isDateInPeriod(NoticePeriod period, LocalDate scheduleDate, Set<ScheduleType> holidayScheduleTypes) {
        if (period == null) {
            return false;
        }

        if (scheduleDate.isBefore(period.validFrom()) || scheduleDate.isAfter(period.validTo())) {
            return false;
        }

        if (period.validFrom().isEqual(period.validTo())) {
            return true;
        }

        if (period.weekdays() == null || period.weekdays().isEmpty()) {
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

    private static List<TafTapLocationReference> findMatchingLocations(Notice notice, Set<TafTapLocationReference> requestedLocations) {
        Set<TafTapLocationReference> configuredLocations = notice.scope() == null ? null : notice.scope().tafTapLocationReferences();
        if (configuredLocations == null || configuredLocations.isEmpty() || requestedLocations == null || requestedLocations.isEmpty()) {
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

    private static NoticeTemplateContent selectNoticeContent(NoticeContent noticeContent, List<String> languagePreferenceOrder) {
        if (noticeContent == null) {
            return null;
        }

        for (String language : languagePreferenceOrder) {
            NoticeTemplateContent selectedContent = switch (language) {
                case "de" -> noticeContent.de();
                case "fr" -> noticeContent.fr();
                case "it" -> noticeContent.it();
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
    public List<NoticeMatch> findMatches(NoticeMatchesRequest filterRequest, String acceptLanguage) {
        List<String> languagePreferenceOrder = resolveLanguagePreferenceOrder(acceptLanguage);
        Set<ScheduleType> holidayScheduleTypes = resolveHolidayScheduleTypes(filterRequest.company(), filterRequest.startDate());
        Map<TafTapLocationReference, List<NoticeTemplateContent>> contentsByLocation = new LinkedHashMap<>();

        noticeRepository.findAll().stream()
            .sorted(Comparator.comparing(Notice::id))
            .filter(notice -> matchesCompany(notice.scope(), filterRequest.company()))
            .filter(notice -> matchesTrainNumber(notice.scope(), filterRequest.operationalTrainNumber()))
            .filter(notice -> matchesDate(notice.periods(), filterRequest.startDate(), holidayScheduleTypes))
            .forEach(notice -> {
                NoticeTemplateContent selectedContent = selectNoticeContent(notice.content(), languagePreferenceOrder);
                if (selectedContent == null) {
                    return;
                }

                findMatchingLocations(notice, filterRequest.tafTapLocationReferences()).forEach(location ->
                    contentsByLocation.computeIfAbsent(location, ignored -> new ArrayList<>()).add(selectedContent));
            });

        return contentsByLocation.entrySet().stream()
            .sorted(Map.Entry.comparingByKey(Comparator.comparing(TafTapLocationReference::toLocationCode)))
            .map(entry -> new NoticeMatch(entry.getKey(), List.copyOf(entry.getValue())))
            .toList();
    }
}


