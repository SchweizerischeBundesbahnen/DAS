package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.NSPListComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.NetworkSpecificParameter;
import ch.sbb.sferamock.messages.model.localregulations.DocumentNode;
import ch.sbb.sferamock.messages.model.localregulations.DocumentRoot;
import ch.sbb.sferamock.messages.model.localregulations.Version;
import com.fasterxml.jackson.core.JsonFactoryBuilder;
import com.fasterxml.jackson.core.StreamReadConstraints;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Service;

@Service
// needs to be run before segement repository
@Order(1)
public class LocalRegulationRepository implements ApplicationRunner {

    private final ObjectMapper objectMapper;
    private final Map<String, List<NSPListComplexType>> localRegulations = new HashMap<>();

    @Value("${localregulations.path}")
    private String filePath;

    @Value("${sfera.company-code}")
    private String tmsCompanyCode;

    public LocalRegulationRepository() {
        this.objectMapper = new ObjectMapper(
            new JsonFactoryBuilder()
                .streamReadConstraints(StreamReadConstraints.builder().maxStringLength(30_000_000).build())
                .build());
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importLocalRegulations();
    }

    private List<NSPListComplexType> createNsps(List<Version> versions) {
        List<NSPListComplexType> nspList = new ArrayList<>();
        for (int i = 0; i < versions.size(); i++) {
            Version version = versions.get(i);
            NSPListComplexType regulation = new NSPListComplexType();
            regulation.setTeltsiCompany(tmsCompanyCode);
            regulation.setNSPGroupName("localRegulation_" + String.format("%05d", i));
            NetworkSpecificParameter titleDe = new NetworkSpecificParameter();
            titleDe.setName("title_de");
            titleDe.setValue(version.title().de());
            NetworkSpecificParameter contentDe = new NetworkSpecificParameter();
            contentDe.setName("contentDe");
            contentDe.setValue(version.content().de());
            NetworkSpecificParameter titleFr = new NetworkSpecificParameter();
            titleFr.setName("title_fr");
            titleFr.setValue(version.title().fr());
            NetworkSpecificParameter contentFr = new NetworkSpecificParameter();
            contentFr.setName("contentFr");
            contentFr.setValue(version.content().fr());
            NetworkSpecificParameter titleIt = new NetworkSpecificParameter();
            titleIt.setName("title_it");
            titleIt.setValue(version.title().it());
            NetworkSpecificParameter contentIt = new NetworkSpecificParameter();
            contentIt.setName("contentIt");
            contentIt.setValue(version.content().it());
            regulation.getNetworkSpecificParameter().addAll(List.of(titleDe, contentDe, titleFr, contentFr, titleIt, contentIt));
            nspList.add(regulation);
        }
        return nspList;
    }

    public List<NSPListComplexType> getLocalRegulations(String abbreviation) {
        return Objects.requireNonNullElse(this.localRegulations.get(abbreviation), Collections.emptyList());
    }

    private void importLocalRegulations() throws IOException {
        File file = new File(filePath);
        try (InputStream in = new FileInputStream(file)) {
            DocumentRoot documentRoot = objectMapper.readValue(in, DocumentRoot.class);
            Map<Integer, List<Version>> result = new HashMap<>();
            collectVersions(documentRoot.document(), result);
            result.forEach((operatingPoint, versions) -> {
                String abbreviation = documentRoot.operatingPoints().get(operatingPoint.toString()).shortTitle();
                if (abbreviation == null || abbreviation.isBlank()) {
                    return;
                }
                localRegulations.put(abbreviation, createNsps(versions));
            });
        }
    }

    private void collectVersions(DocumentNode document, Map<Integer, List<Version>> result) {
        for (Version version : document.versions()) {
            for (Integer operatingPoint : version.operatingPoints()) {
                result.computeIfAbsent(operatingPoint, key -> new ArrayList<>()).add(version);
            }
        }
        for (DocumentNode child : document.children()) {
            collectVersions(child, result);
        }
    }
}
