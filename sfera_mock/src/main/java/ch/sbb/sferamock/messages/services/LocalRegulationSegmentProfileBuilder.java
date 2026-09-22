package ch.sbb.sferamock.messages.services;

import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.LR_PREFIX;
import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.NSP_GROUP_NAME;
import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.createNsp;
import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.formatDate;
import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.getLocalizedValue;
import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.selectInForceVersion;

import ch.sbb.sferamock.adapters.sfera.model.v0400.NSPListComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0400.NetworkSpecificPoint;
import ch.sbb.sferamock.adapters.sfera.model.v0400.SPPoints;
import ch.sbb.sferamock.adapters.sfera.model.v0400.SPZoneComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0400.SegmentProfile;
import ch.sbb.sferamock.messages.model.localregulations.DocumentNode;
import ch.sbb.sferamock.messages.model.localregulations.DocumentRoot;
import ch.sbb.sferamock.messages.model.localregulations.Version;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class LocalRegulationSegmentProfileBuilder {

    private static final String SP_VERSION_MAJOR = "0";
    private static final List<String> LANGUAGES = List.of("DE", "FR", "IT");

    @Value("${sfera.company-code}")
    private String tmsCompanyCode;

    public Map<String, SegmentProfile> buildSegmentProfiles(DocumentNode documentRoot,
        Map<DocumentNode, Integer> nodeIds,
        Map<DocumentNode, List<Integer>> nodeChildIds) {
        Map<String, SegmentProfile> segmentProfiles = new HashMap<>();
        buildSegmentProfilesRecursively(documentRoot, nodeIds, nodeChildIds, segmentProfiles);
        return segmentProfiles;
    }

    public Map<String, List<NSPListComplexType>> buildOperatingPointNsps(DocumentRoot documentRoot,
        Map<DocumentNode, Integer> nodeIds) {
        Map<String, List<NSPListComplexType>> localRegulationNsps = new HashMap<>();
        Map<Integer, List<Integer>> opToNodeIds = new HashMap<>();
        collectOperatingPointNodes(documentRoot.document(), nodeIds, opToNodeIds);

        for (Map.Entry<Integer, List<Integer>> entry : opToNodeIds.entrySet()) {
            Integer opId = entry.getKey();
            var opInfo = documentRoot.operatingPoints().get(opId.toString());
            if (opInfo == null || opInfo.shortTitle() == null || opInfo.shortTitle().isBlank()) {
                continue;
            }
            String abbreviation = opInfo.shortTitle();
            List<Integer> nodeIdsForOp = entry.getValue();
            if (nodeIdsForOp.isEmpty()) {
                continue;
            }

            String treeValue = nodeIdsForOp.stream()
                .map(id -> LR_PREFIX + id)
                .reduce((a, b) -> a + ";" + b)
                .orElse("");

            NSPListComplexType nspList = new NSPListComplexType();
            nspList.setTeltsiCompany(tmsCompanyCode);
            nspList.setNSPGroupName(NSP_GROUP_NAME);
            nspList.getNetworkSpecificParameter().add(createNsp("languageNeutralTree", treeValue));

            localRegulationNsps.computeIfAbsent(abbreviation, k -> new ArrayList<>()).add(nspList);
        }

        return localRegulationNsps;
    }

    private void buildSegmentProfilesRecursively(DocumentNode node,
        Map<DocumentNode, Integer> nodeIds,
        Map<DocumentNode, List<Integer>> nodeChildIds,
        Map<String, SegmentProfile> segmentProfiles) {
        int nodeId = nodeIds.get(node);
        List<Integer> childIds = nodeChildIds.get(node);

        selectInForceVersion(node.versions()).ifPresent(version -> {
            for (String lang : LANGUAGES) {
                String spId = LR_PREFIX + nodeId + "_" + lang;
                SegmentProfile sp = createLocalRegulationSegmentProfile(spId, version, lang, childIds);
                segmentProfiles.put(spId, sp);
            }
        });

        // If the node has no versions but has children, still create minimal SPs
        if (node.versions().isEmpty()) {
            for (String lang : LANGUAGES) {
                String spId = LR_PREFIX + nodeId + "_" + lang;
                SegmentProfile sp = createMinimalLocalRegulationSegmentProfile(spId, childIds);
                segmentProfiles.put(spId, sp);
            }
        }

        for (DocumentNode child : node.children()) {
            buildSegmentProfilesRecursively(child, nodeIds, nodeChildIds, segmentProfiles);
        }
    }

    private SegmentProfile createLocalRegulationSegmentProfile(String spId, Version version,
        String lang, List<Integer> childIds) {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID(spId);
        sp.setSPVersionMajor(SP_VERSION_MAJOR);
        sp.setSPLength(0);

        SPZoneComplexType zone = new SPZoneComplexType();
        zone.setIMID(tmsCompanyCode);
        sp.setSPZone(zone);

        NetworkSpecificPoint nsp = new NetworkSpecificPoint();
        nsp.setTeltsiCompany(tmsCompanyCode);
        nsp.setLocation(0);
        nsp.setNSPGroupName(NSP_GROUP_NAME);

        String title = getLocalizedValue(version.title().de(), version.title().fr(), version.title().it(), lang);
        if (title != null) {
            nsp.getNetworkSpecificParameter().add(createNsp("title", title));
        }

        String content = getLocalizedValue(version.content().de(), version.content().fr(), version.content().it(), lang);
        if (content != null) {
            nsp.getNetworkSpecificParameter().add(createNsp("content", content));
        }

        if (!childIds.isEmpty()) {
            String childrenValue = childIds.stream()
                .map(id -> LR_PREFIX + id)
                .reduce((a, b) -> a + ";" + b)
                .orElse("");
            nsp.getNetworkSpecificParameter().add(createNsp("children", childrenValue));
        }

        if (version.inForceFrom() != null && !version.inForceFrom().isBlank()) {
            String beginDate = formatDate(version.inForceFrom());
            if (beginDate != null) {
                nsp.getNetworkSpecificParameter().add(createNsp("beginDate", beginDate));
            }
        }

        if (version.inForceTo() != null && !version.inForceTo().isBlank()) {
            String endDate = formatDate(version.inForceTo());
            if (endDate != null) {
                nsp.getNetworkSpecificParameter().add(createNsp("endDate", endDate));
            }
        }

        SPPoints points = new SPPoints();
        points.getNetworkSpecificPoint().add(nsp);
        sp.setSPPoints(points);

        return sp;
    }

    private SegmentProfile createMinimalLocalRegulationSegmentProfile(String spId, List<Integer> childIds) {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID(spId);
        sp.setSPVersionMajor(SP_VERSION_MAJOR);
        sp.setSPLength(0);

        SPZoneComplexType zone = new SPZoneComplexType();
        zone.setIMID(tmsCompanyCode);
        sp.setSPZone(zone);

        if (!childIds.isEmpty()) {
            NetworkSpecificPoint nsp = new NetworkSpecificPoint();
            nsp.setTeltsiCompany(tmsCompanyCode);
            nsp.setLocation(0);
            nsp.setNSPGroupName(NSP_GROUP_NAME);

            String childrenValue = childIds.stream()
                .map(id -> LR_PREFIX + id)
                .reduce((a, b) -> a + ";" + b)
                .orElse("");
            nsp.getNetworkSpecificParameter().add(createNsp("children", childrenValue));

            SPPoints points = new SPPoints();
            points.getNetworkSpecificPoint().add(nsp);
            sp.setSPPoints(points);
        }

        return sp;
    }

    private void collectOperatingPointNodes(DocumentNode node,
        Map<DocumentNode, Integer> nodeIds,
        Map<Integer, List<Integer>> opToNodeIds) {
        int nodeId = nodeIds.get(node);

        for (Version version : node.versions()) {
            for (Integer opId : version.operatingPoints()) {
                opToNodeIds.computeIfAbsent(opId, k -> new ArrayList<>()).add(nodeId);
            }
        }

        for (DocumentNode child : node.children()) {
            collectOperatingPointNodes(child, nodeIds, opToNodeIds);
        }
    }
}
