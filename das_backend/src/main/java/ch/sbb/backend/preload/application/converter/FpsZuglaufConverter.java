package ch.sbb.backend.preload.application.converter;

import ch.sbb.backend.preload.application.BitSetUtil;
import ch.sbb.backend.preload.application.model.dailytrainrun.OperationPoint;
import ch.sbb.backend.preload.application.model.dailytrainrun.TrainRun;
import ch.sbb.backend.preload.application.model.dailytrainrun.TrainRunDate;
import ch.sbb.backend.preload.application.model.dailytrainrun.TrainRunPoint;
import ch.sbb.backend.preload.infrastructure.model.traindata.Betriebspunkt;
import ch.sbb.backend.preload.infrastructure.model.traindata.Zuglauf;
import ch.sbb.backend.preload.infrastructure.model.traindata.Zuglaufpunkt;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.val;
import org.springframework.stereotype.Component;

@Component
public class FpsZuglaufConverter {

    static final int UIC_COUNTRY_CODE_CH = 85;

    private static final String HALTEZWECK_HALT_AUF_VERLANGEN = "14";

    private static final ZoneId CET = ZoneId.of("CET");

    List<TrainRun> convertFpsZuglauefe(List<Zuglauf> zuglaeufe, LocalDate periodStartDate) {
        return zuglaeufe.stream()
            .filter(zuglauf -> nullSafeTrue(zuglauf.getVerkehrt()))
            .map(zuglauf -> {
                val operationalDates = convertSollTage(periodStartDate, zuglauf.getSolltageVp().getTage());
                return convertFpsZuglauf(zuglaeufe, zuglauf, operationalDates);
            })
            .toList();
    }

    private boolean nullSafeTrue(Boolean verkehrt) {
        return verkehrt != null && verkehrt;
    }

    private List<LocalDate> convertSollTage(LocalDate periodStartDate, String sollTage) {
        return IntStream.range(0, sollTage.length())
            .filter(index -> BitSetUtil.isDaySet(index, sollTage))
            .mapToObj(periodStartDate::plusDays)
            .toList();
    }

    private TrainRun convertFpsZuglauf(List<Zuglauf> zuglaeufe, Zuglauf zuglauf, List<LocalDate> operationalDates) {
        val zuglaufPunkte = convertZuglaufPunkte(zuglauf.getZuglaufpunkte());

        Optional<Integer> firstDepartureTime = findFirstDepartureTime(zuglaufPunkte);
        val trainRunDates = new ArrayList<TrainRunDate>();

        operationalDates.forEach(
            operationalDate -> {
                val startDate = convertToStartDate(operationalDate, firstDepartureTime);
                if (startDate.isAfter(LocalDate.now().minusDays(3))) {
                    trainRunDates.add(TrainRunDate.builder()
                        .operationalDate(operationalDate)
                        .startDate(startDate)
                        .build());
                }
            });

        return TrainRun.builder()
            .firstDepartureTime(firstDepartureTime)
            .smsRUs(collectSmsRUs(zuglaeufe))
            .trainRunDates(trainRunDates)
            .trainRunPoints(zuglaufPunkte)
            .build();
    }

    private Optional<Integer> findFirstDepartureTime(List<TrainRunPoint> zuglaufPunkte) {
        return zuglaufPunkte.stream()
            .filter(it -> it.getOperationPoint().getCountryCode() == UIC_COUNTRY_CODE_CH)
            .map(TrainRunPoint::getCommercialDepartureTime)
            .filter(Objects::nonNull)
            .findFirst()
            .or(() -> zuglaufPunkte.stream()
                .filter(it -> it.getOperationPoint().getCountryCode() == UIC_COUNTRY_CODE_CH)
                .map(TrainRunPoint::getOperationalDepartureTime)
                .filter(Objects::nonNull)
                .findFirst());
    }

    private LocalDate convertToStartDate(LocalDate operationalDate, Optional<Integer> firstSwissOperationalDepartureTime) {
        if (firstSwissOperationalDepartureTime.isPresent()) {
            int departureTime = firstSwissOperationalDepartureTime.get();
            return plusSeconds(operationalDate, departureTime);
        }
        return operationalDate;
    }

    private LocalDate plusSeconds(LocalDate operationalDate, int departureTime) {
        ZonedDateTime dateTime = ZonedDateTime.of(
            operationalDate.getYear(), operationalDate.getMonth().getValue(), operationalDate.getDayOfMonth(),
            0, 0, 0, 0,
            CET);
        return dateTime.plusSeconds(departureTime).toLocalDate();
    }

    private Set<String> collectSmsRUs(List<Zuglauf> zuglaeufe) {
        return zuglaeufe.stream()
            .flatMap(zuglauf -> zuglauf.getZuglaufpunkte().stream())
            .flatMap(zuglaufpunkt -> Optional.ofNullable(zuglaufpunkt.getSmsEvu()).stream())
            .collect(Collectors.toSet());
    }

    private List<TrainRunPoint> convertZuglaufPunkte(List<Zuglaufpunkt> zuglaufpunkte) {
        return zuglaufpunkte.stream()
            .map(zuglaufpunkt -> TrainRunPoint.builder()
                .operationPoint(convertBetriebspunkt(zuglaufpunkt.getBetriebspunkt()))
                .commercialDepartureTime(zuglaufpunkt.getKommZeitAb())
                .commercialArrivalTime(zuglaufpunkt.getKommZeitAn())
                .operationalDepartureTime(zuglaufpunkt.getBetrZeitAb())
                .operationalArrivalTime(zuglaufpunkt.getBetrZeitAn())
                .mandatoryStop(isMandatoryStop(zuglaufpunkt))
                .build())
            .toList();
    }

    private static boolean isMandatoryStop(Zuglaufpunkt zuglaufpunkt) {
        return zuglaufpunkt.getHalt() != null && !zuglaufpunkt.getHalt().getHaltezwecke().contains(HALTEZWECK_HALT_AUF_VERLANGEN);
    }

    private OperationPoint convertBetriebspunkt(Betriebspunkt betriebspunkt) {
        return OperationPoint.builder()
            .abbreviation(betriebspunkt.getBpAbkuerzung())
            .uicCode(betriebspunkt.getBpUicCode())
            .countryCode(betriebspunkt.getBpUicLaendercode())
            .build();
    }

}
