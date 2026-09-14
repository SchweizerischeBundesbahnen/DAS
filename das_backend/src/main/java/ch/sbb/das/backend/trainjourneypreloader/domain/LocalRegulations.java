package ch.sbb.das.backend.trainjourneypreloader.domain;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.w3c.dom.Element;

public final class LocalRegulations {

    static final String NSP_GROUP_NAME = "localRegulations";
    static final String NSP_LANGUAGE_NEUTRAL_TREE = "languageNeutralTree";
    static final String SP_VERSION_MAJOR = "0";
    static final String TREE_SEPARATOR = ";";
    static final String ID_LANGUAGE_SEPARATOR = "_";

    static final List<String> LANGUAGES = List.of("DE", "FR", "IT");

    private LocalRegulations() {
    }

    public static Set<SegmentProfileIdentification> extractSpIds(SegmentProfile segmentProfile) {
        if (segmentProfile.getSPAreas() == null) {
            return Set.of();
        }
        String imid = segmentProfile.getSPZone().getIMID();
        Set<SegmentProfileIdentification> ids = new HashSet<>();
        segmentProfile.getSPAreas().getTAFTAPLocations().forEach(location ->
            location.getTAFTAPLocationNSPs().stream()
                .filter(nsp -> NSP_GROUP_NAME.equals(nspGroupName(nsp.getNSPGroupName())))
                .flatMap(nsp -> nsp.getNetworkSpecificParameters().stream())
                .filter(param -> NSP_LANGUAGE_NEUTRAL_TREE.equals(param.getName()))
                .forEach(param -> ids.addAll(expand(param.getValue(), imid))));
        return ids;
    }

    private static Set<SegmentProfileIdentification> expand(String nspValue, String imid) {
        if (nspValue == null || nspValue.isBlank()) {
            return Set.of();
        }
        Set<SegmentProfileIdentification> ids = new HashSet<>();
        for (String neutralId : nspValue.split(TREE_SEPARATOR)) {
            String trimmed = neutralId.trim();
            if (trimmed.isEmpty()) {
                continue;
            }
            for (String lang : LANGUAGES) {
                ids.add(new SegmentProfileIdentification(trimmed + ID_LANGUAGE_SEPARATOR + lang, SP_VERSION_MAJOR, null, imid, null));
            }
        }
        return ids;
    }

    // Reads the NSP group name as text. The SFERA schema element has no type
    private static String nspGroupName(Object nspGroupName) {
        return switch (nspGroupName) {
            case String s -> s;
            case Element e -> e.getTextContent();
            case null, default -> null;
        };
    }
}
