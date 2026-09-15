package ch.sbb.sferamock.messages.services;

import static ch.sbb.sferamock.messages.services.LocalRegulationNspFactory.LR_PREFIX;

import ch.sbb.sferamock.adapters.sfera.model.v0400.NSPListComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0400.SegmentProfile;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Service;

@Service
@Slf4j
// needs to be run before segement repository
@Order(1)
public class LocalRegulationRepository implements ApplicationRunner {

    private final LocalRegulationParser localRegulationParser;
    private final LocalRegulationSegmentProfileBuilder localRegulationSegmentProfileBuilder;
    private final Map<String, SegmentProfile> localRegulationSegmentProfiles = new HashMap<>();
    private final Map<String, List<NSPListComplexType>> localRegulationNsps = new HashMap<>();

    @Value("${localregulations.path}")
    private String filePath;

    public LocalRegulationRepository(LocalRegulationParser localRegulationParser, LocalRegulationSegmentProfileBuilder localRegulationSegmentProfileBuilder) {
        this.localRegulationParser = localRegulationParser;
        this.localRegulationSegmentProfileBuilder = localRegulationSegmentProfileBuilder;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importLocalRegulations();
    }

    public List<NSPListComplexType> getLocalRegulationNsps(String abbreviation) {
        return Objects.requireNonNullElse(this.localRegulationNsps.get(abbreviation), Collections.emptyList());
    }

    public SegmentProfile getLocalRegulationSegmentProfile(String spId) {
        return localRegulationSegmentProfiles.get(spId);
    }

    public boolean isLocalRegulationSpId(String spId) {
        return spId != null && spId.startsWith(LR_PREFIX);
    }

    private void importLocalRegulations() throws IOException {
        if (filePath == null || filePath.isBlank()) {
            log.warn("Local regulations file path is not configured, skipping.");
            return;
        }
        try {
            var documentRoot = localRegulationParser.loadDocument(filePath);
            var treeResult = localRegulationParser.processTree(documentRoot.document());
            var segmentProfiles = localRegulationSegmentProfileBuilder.buildSegmentProfiles(documentRoot.document(), treeResult.nodeIds(), treeResult.nodeChildIds());
            localRegulationSegmentProfiles.putAll(segmentProfiles);
            var nsps = localRegulationSegmentProfileBuilder.buildOperatingPointNsps(documentRoot, treeResult.nodeIds());
            localRegulationNsps.putAll(nsps);
            log.info("Loaded {} local regulation segment profiles for {} operating points.", localRegulationSegmentProfiles.size(), localRegulationNsps.size());
        } catch (Exception e) {
            log.error("Failed to load local regulations from {}: {}", filePath, e.getMessage(), e);
            throw new IOException("Failed to load local regulations", e);
        }
    }
}
