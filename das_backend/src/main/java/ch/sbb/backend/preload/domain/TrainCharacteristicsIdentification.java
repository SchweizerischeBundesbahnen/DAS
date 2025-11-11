package ch.sbb.backend.preload.domain;

import ch.sbb.backend.preload.sfera.model.v0300.TCRequest;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristicsRef;

public record TrainCharacteristicsIdentification(String tcid, String tcVersionMajor, String tcVersionMinor, String tcruid) {

    public static TrainCharacteristicsIdentification from(TrainCharacteristicsRef tcRef) {
        return new TrainCharacteristicsIdentification(tcRef.getTCID(), tcRef.getTCVersionMajor(), tcRef.getTCVersionMinor(), tcRef.getTCRUID());
    }

    public static TrainCharacteristicsIdentification from(TrainCharacteristics tc) {
        return new TrainCharacteristicsIdentification(tc.getTCID(), tc.getTCVersionMajor(), tc.getTCVersionMinor(), tc.getTCRUID());
    }

    public TCRequest toTcRequest() {
        TCRequest tcRequest = new TCRequest();
        tcRequest.setTCID(tcid);
        tcRequest.setTCVersionMajor(tcVersionMajor);
        tcRequest.setTCVersionMinor(tcVersionMinor);
        tcRequest.setTCRUID(tcruid);
        return tcRequest;
    }
}
