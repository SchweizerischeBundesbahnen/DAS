package ch.sbb.backend.preload;

import ch.sbb.backend.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristics;
import java.util.List;

public class PreloadStorageService {

    public void save(List<JourneyProfile> journeyProfiles, List<SegmentProfile> segmentProfiles, List<TrainCharacteristics> trainCharacteristics) {
        // TODO implement
        //  * convert to files
        //  * structure in directories
        //  * compress to zip file
        //  * upload to S3
    }

    public void cleanUp() {
        // TODO implement
        //  * delete old files (created > 24h) from S3
    }
}
