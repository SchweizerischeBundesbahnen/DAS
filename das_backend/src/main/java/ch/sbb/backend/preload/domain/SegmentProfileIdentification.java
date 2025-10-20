package ch.sbb.backend.preload.domain;

import ch.sbb.backend.preload.sfera.model.v0300.SPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.SPZoneComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfileReference;

public record SegmentProfileIdentification(String spid, String spVersionMajor, String spVersionMinor, String imid, Short nidc) {

    public static SegmentProfileIdentification from(SegmentProfile sp) {
        return new SegmentProfileIdentification(sp.getSPID(),
            sp.getSPVersionMajor(),
            sp.getSPVersionMinor(),
            sp.getSPZone().getIMID(),
            sp.getSPZone().getNIDC());
    }

    public static SegmentProfileIdentification from(SegmentProfileReference spRef) {
        return new SegmentProfileIdentification(spRef.getSPID(),
            spRef.getSPVersionMajor(),
            spRef.getSPVersionMinor(),
            spRef.getSPZone().getIMID(),
            spRef.getSPZone().getNIDC());
    }

    public SPRequest toSpRequest() {
        SPRequest spRequest = new SPRequest();
        spRequest.setSPID(spid);
        spRequest.setSPVersionMajor(spVersionMajor);
        spRequest.setSPVersionMinor(spVersionMinor);
        SPZoneComplexType spZone = new SPZoneComplexType();
        spZone.setIMID(imid);
        spZone.setNIDC(nidc);
        spRequest.setSPZone(spZone);
        return spRequest;
    }

}
