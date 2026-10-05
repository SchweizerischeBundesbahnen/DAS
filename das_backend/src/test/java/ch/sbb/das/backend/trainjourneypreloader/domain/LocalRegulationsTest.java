package ch.sbb.das.backend.trainjourneypreloader.domain;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.NSPListComplexType;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.NetworkSpecificParameter;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPAreas;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPZone;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TAFTAPLocation;
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Test;

class LocalRegulationsTest {

    private static SegmentProfile regularSpWithLanguageNeutralTree(String imid, String treeValue) {
        return spWithNsp(imid, LocalRegulations.NSP_GROUP_NAME, LocalRegulations.NSP_LANGUAGE_NEUTRAL_TREE, treeValue);
    }

    private static SegmentProfile spWithNsp(String imid, String groupName, String paramName, String paramValue) {
        SegmentProfile sp = new SegmentProfile();
        SPZone zone = new SPZone();
        zone.setIMID(imid);
        sp.setSPZone(zone);

        SPAreas areas = new SPAreas();
        TAFTAPLocation location = new TAFTAPLocation();
        NSPListComplexType nsp = new NSPListComplexType();
        nsp.setNSPGroupName(groupName);
        NetworkSpecificParameter param = new NetworkSpecificParameter();
        param.setName(paramName);
        param.setValue(paramValue);
        nsp.getNetworkSpecificParameters().add(param);
        location.getTAFTAPLocationNSPs().add(nsp);
        areas.getTAFTAPLocations().add(location);
        sp.setSPAreas(areas);
        return sp;
    }

    @Test
    void extractSpIds_whenLanguageNeutralTreePresent_expandsCompleteTreePerLanguage() {
        SegmentProfile sp = regularSpWithLanguageNeutralTree("0085", "LR_846;LR_847");

        Set<SegmentProfileIdentification> ids = LocalRegulations.extractSpIds(sp);

        assertThat(ids.stream().map(SegmentProfileIdentification::spid).collect(Collectors.toSet()))
            .containsExactlyInAnyOrder(
                "LR_846_DE", "LR_846_FR", "LR_846_IT",
                "LR_847_DE", "LR_847_FR", "LR_847_IT");
        assertThat(ids).allSatisfy(id -> {
            assertThat(id.spVersionMajor()).isEqualTo("0");
            assertThat(id.spVersionMinor()).isNull();
            assertThat(id.nidc()).isNull();
        });
    }

    @Test
    void extractSpIds_usesImIdFromHostingSegmentProfileZone() {
        SegmentProfile sp = regularSpWithLanguageNeutralTree("0011", "LR_1");

        Set<SegmentProfileIdentification> ids = LocalRegulations.extractSpIds(sp);

        assertThat(ids)
            .isNotEmpty()
            .allSatisfy(id -> assertThat(id.imid()).isEqualTo("0011"));
    }

    @Test
    void extractSpIds_whenNoSpAreas_returnsEmpty() {
        assertThat(LocalRegulations.extractSpIds(new SegmentProfile())).isEmpty();
    }

    @Test
    void extractSpIds_whenNspGroupNotLocalRegulations_ignoresIt() {
        SegmentProfile sp = spWithNsp("0085", "stationSpeed", "languageNeutralTree", "LR_1");
        assertThat(LocalRegulations.extractSpIds(sp)).isEmpty();
    }

    @Test
    void extractSpIds_whenTreeHasBlankEntries_ignoresBlanks() {
        SegmentProfile sp = regularSpWithLanguageNeutralTree("0085", "LR_1; ;LR_2;");

        Set<SegmentProfileIdentification> ids = LocalRegulations.extractSpIds(sp);

        assertThat(ids.stream().map(SegmentProfileIdentification::spid).collect(Collectors.toSet()))
            .containsExactlyInAnyOrder("LR_1_DE", "LR_1_FR", "LR_1_IT", "LR_2_DE", "LR_2_FR", "LR_2_IT");
    }
}
