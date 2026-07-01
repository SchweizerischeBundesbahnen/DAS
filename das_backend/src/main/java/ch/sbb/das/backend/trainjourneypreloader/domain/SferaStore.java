package ch.sbb.das.backend.trainjourneypreloader.domain;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class SferaStore {

    // TODO consider using a cache with eviction strategy or cleanup if memory becomes an issue
    private final Map<TrainCharacteristicsIdentification, TrainCharacteristics> trainCharacteristics = new HashMap<>();

    public void addTcs(List<TrainCharacteristics> tcs) {
        Map<TrainCharacteristicsIdentification, TrainCharacteristics> map = tcs.stream().collect(Collectors.toMap(TrainCharacteristicsIdentification::from, tc -> tc));
        trainCharacteristics.putAll(map);
    }

    public TrainCharacteristics getTc(TrainCharacteristicsIdentification trainCharacteristicsIdentification) {
        return trainCharacteristics.get(trainCharacteristicsIdentification);
    }
}
