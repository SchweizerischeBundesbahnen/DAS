package ch.sbb.backend.preload.domain;

import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class SferaStore {

    private final Map<SegmentProfileIdentification, SegmentProfile> segmentProfiles = new HashMap<>();
    private final Map<TrainCharacteristicsIdentification, TrainCharacteristics> trainCharacteristics = new HashMap<>();

    public void addSps(List<SegmentProfile> sps) {
        Map<SegmentProfileIdentification, SegmentProfile> map = sps.stream().collect(Collectors.toMap(SegmentProfileIdentification::from, sp -> sp));
        segmentProfiles.putAll(map);
    }

    public void addTcs(List<TrainCharacteristics> tcs) {
        Map<TrainCharacteristicsIdentification, TrainCharacteristics> map = tcs.stream().collect(Collectors.toMap(TrainCharacteristicsIdentification::from, tc -> tc));
        trainCharacteristics.putAll(map);
    }

    public SegmentProfile getSp(SegmentProfileIdentification segmentProfileIdentification) {
        return segmentProfiles.get(segmentProfileIdentification);
    }
    
    public TrainCharacteristics getTc(TrainCharacteristicsIdentification trainCharacteristicsIdentification) {
        return trainCharacteristics.get(trainCharacteristicsIdentification);
    }
}
