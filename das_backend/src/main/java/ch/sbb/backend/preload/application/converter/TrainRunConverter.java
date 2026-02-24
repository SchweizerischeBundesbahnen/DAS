package ch.sbb.backend.preload.application.converter;

import ch.sbb.backend.preload.application.BitSetUtil;
import ch.sbb.backend.preload.application.model.trainidentification.TrainRun;
import ch.sbb.backend.preload.application.model.trainidentification.TrainRunDate;
import ch.sbb.backend.preload.application.model.trainidentification.TrainRunPoint;
import ch.sbb.backend.preload.infrastructure.model.train.Zuglauf;
import ch.sbb.backend.preload.infrastructure.model.train.Zuglaufpunkt;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.springframework.stereotype.Component;

@Component
public class TrainRunConverter {

    static final int UIC_COUNTRY_CODE_CH = 85;

    private static final ZoneId CET = ZoneId.of("CET");

    List<TrainRun> convertTrainRuns(List<Zuglauf> zuglaeufe, LocalDate periodStartDate) {
        return zuglaeufe.stream()
            .filter(zuglauf -> nullSafeTrue(zuglauf.getVerkehrt()))
            .map(zuglauf -> {
                List<LocalDate> operationalDays = convertDates(periodStartDate, zuglauf.getSolltageVp().getTage());
                return convertTrainRun(zuglaeufe, zuglauf, operationalDays);
            })
            .filter(Objects::nonNull)
            .toList();
    }

    private boolean nullSafeTrue(Boolean verkehrt) {
        return verkehrt != null && verkehrt;
    }

    private List<LocalDate> convertDates(LocalDate periodStartDate, String sollTage) {
        return IntStream.range(0, sollTage.length())
            .filter(index -> BitSetUtil.isDaySet(index, sollTage))
            .mapToObj(periodStartDate::plusDays)
            .toList();
    }

    private TrainRun convertTrainRun(List<Zuglauf> zuglaeufe, Zuglauf zuglauf, List<LocalDate> operationalDays) {
        List<TrainRunPoint> zuglaufPunkte = convertTrainRunPoints(zuglauf.getZuglaufpunkte());

        Optional<Integer> firstDepartureTime = findFirstDepartureTime(zuglaufPunkte);
        if (firstDepartureTime.isEmpty()) {
            return null;
        }
        List<TrainRunDate> trainRunDates = new ArrayList<>();

        operationalDays.forEach(
            operationalDate -> {
                OffsetDateTime startDate = convertToStartDate(operationalDate, firstDepartureTime);
                if (startDate.isAfter(OffsetDateTime.now().minusDays(3))) {
                    trainRunDates.add(TrainRunDate.builder()
                        .operationalDate(operationalDate)
                        .startDateTime(startDate)
                        .build());
                }
            });

        return TrainRun.builder()
            .firstDepartureTime(firstDepartureTime.get())
            .companies(collectCompanies(zuglaeufe))
            .trainRunDates(trainRunDates)
            .build();
    }

    private Optional<Integer> findFirstDepartureTime(List<TrainRunPoint> zuglaufPunkte) {
        return findFirstSwissDepartureTime(zuglaufPunkte, TrainRunPoint::getCommercialDepartureTime)
            .or(() -> findFirstSwissDepartureTime(zuglaufPunkte, TrainRunPoint::getOperationalDepartureTime));
    }

    private Optional<Integer> findFirstSwissDepartureTime(List<TrainRunPoint> zuglaufPunkte, Function<TrainRunPoint, Integer> departureTimeExtractor) {
        return zuglaufPunkte.stream()
            .filter(it -> it.getCountryCode() == UIC_COUNTRY_CODE_CH)
            .map(departureTimeExtractor)
            .filter(Objects::nonNull)
            .findFirst();
    }

    private OffsetDateTime convertToStartDate(LocalDate operationalDate, Optional<Integer> firstSwissOperationalDepartureTime) {
        return plusSeconds(operationalDate, firstSwissOperationalDepartureTime.orElse(0));
    }

    private OffsetDateTime plusSeconds(LocalDate operationalDate, int departureTime) {
        ZonedDateTime dateTime = ZonedDateTime.of(
            operationalDate.getYear(), operationalDate.getMonth().getValue(), operationalDate.getDayOfMonth(),
            0, 0, 0, 0,
            CET);
        return dateTime.plusSeconds(departureTime).toOffsetDateTime();
    }

    private Set<String> collectCompanies(List<Zuglauf> zuglaeufe) {
        return zuglaeufe.stream()
            .flatMap(zuglauf -> zuglauf.getZuglaufpunkte().stream())
            .flatMap(zuglaufpunkt -> Optional.ofNullable(zuglaufpunkt.getSmsEvu()).stream())
            .collect(Collectors.toSet());
    }

    private List<TrainRunPoint> convertTrainRunPoints(List<Zuglaufpunkt> zuglaufpunkte) {
        return zuglaufpunkte.stream()
            .map(zuglaufpunkt -> TrainRunPoint.builder()
                .countryCode(zuglaufpunkt.getBetriebspunkt().getBpUicLaendercode())
                .commercialDepartureTime(zuglaufpunkt.getKommZeitAb())
                .operationalDepartureTime(zuglaufpunkt.getBetrZeitAb())
                .build())
            .toList();
    }
}
