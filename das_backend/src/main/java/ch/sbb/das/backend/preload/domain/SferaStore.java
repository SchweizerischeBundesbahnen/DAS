package ch.sbb.das.backend.preload.domain;

import ch.sbb.das.backend.preload.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.preload.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.TrainCharacteristics;

import java.util.*;
import java.util.stream.Collectors;

public class SferaStore {

    // TODO consider using a cache with eviction strategy or cleanup if memory becomes an issue
    private final Map<SegmentProfileIdentification, SegmentProfile> segmentProfiles = new HashMap<>();
    private final Map<TrainCharacteristicsIdentification, TrainCharacteristics> trainCharacteristics = new HashMap<>();
    private final Set<String> preloadedSegmentProfileIds = new HashSet<>();

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

    public void addPreloadedSegmentProfile(PreloadedSegmentProfileEntity preloadedSegmentProfileEntity) {
        preloadedSegmentProfileIds.add(preloadedSegmentProfileEntity.getId());
    }

    public boolean hasPreloadedSegmentProfile(SegmentProfileIdentification segmentProfile) {
        return preloadedSegmentProfileIds.contains(String.format("%s_%s_%s", segmentProfile.spid(), segmentProfile.spVersionMajor(), segmentProfile.spVersionMinor()));
    }
}
