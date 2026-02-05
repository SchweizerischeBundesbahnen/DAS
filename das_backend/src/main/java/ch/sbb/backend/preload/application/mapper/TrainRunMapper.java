package ch.sbb.backend.preload.application.mapper;

import ch.sbb.backend.preload.application.TimeConverter;
import ch.sbb.backend.preload.application.UicCompanyCodeProvider;
import ch.sbb.backend.preload.application.model.dailytrainrun.CompanyCode;
import ch.sbb.backend.preload.application.model.dailytrainrun.TrainIdentification;
import ch.sbb.backend.preload.application.model.dailytrainrun.TrainRunPoint;
import ch.sbb.backend.preload.infrastructure.model.entities.TrainRunViewEntity;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jdk8.Jdk8Module;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class TrainRunMapper {

    private final ObjectMapper objectMapper;

    private final UicCompanyCodeProvider uicCompanyCodeProvider;

    public TrainRunMapper(UicCompanyCodeProvider uicCompanyCodeProvider) {
        this.uicCompanyCodeProvider = uicCompanyCodeProvider;
        objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .registerModule(new Jdk8Module());
    }

    public String toEntity(List<TrainRunPoint> trainRunPoints) throws JsonProcessingException {
        return objectMapper.writeValueAsString(trainRunPoints);
    }

    public Optional<TrainIdentification> readEntity(TrainRunViewEntity trainRunEntity) {
        try {
            List<TrainRunPoint> trainRunPoints = Arrays.stream(objectMapper.readValue(
                    trainRunEntity.getTrainRunPoints(), TrainRunPoint[].class))
                .filter(trainRunPoint -> trainRunPoint.getOperationalDepartureTime() != null)
                .sorted(Comparator.comparing(TrainRunPoint::getOperationalDepartureTime)).toList();

            val operationalDate = trainRunEntity.getId().getOperationalDate();

            val dailyTrainRun = TrainIdentification.builder()
                .startDate(trainRunEntity.getStartDate())
                .operationalTrainNumber(trainRunEntity.getTrainNumber())
                .departureTime(toInstant(operationalDate, trainRunPoints.getFirst().getOperationalDepartureTime()))
                .companies(readCompanyCodes(trainRunEntity.getSmsRus()))
                .build();

            return Optional.of(dailyTrainRun);

        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize TrainRunPoints for TrainRunEntity with pathId {}: {}",
                trainRunEntity.getId().getPathId(), e.getMessage());
            return Optional.empty();
        }
    }

    private Set<CompanyCode> readCompanyCodes(String smsRus) {
        return Set.of(smsRus.split(",")).stream()
            .map(uicCompanyCodeProvider::getUicCompanyCode)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .collect(Collectors.toSet());
    }

    private OffsetDateTime toInstant(LocalDate operationalDate, Integer time) {
        return time == null
            ? null
            : TimeConverter.convertTime(operationalDate, time);
    }
}
