package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.messages.model.localregulations.DocumentNode;
import ch.sbb.sferamock.messages.model.localregulations.DocumentRoot;
import java.io.IOException;
import java.io.InputStream;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;
import tools.jackson.core.StreamReadConstraints;
import tools.jackson.core.json.JsonFactoryBuilder;
import tools.jackson.databind.json.JsonMapper;

@Component
public class LocalRegulationParser {

    private final ResourceLoader resourceLoader;
    private final JsonMapper objectMapper;

    public LocalRegulationParser(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
        this.objectMapper = new JsonMapper(
            new JsonFactoryBuilder()
                // Raise Jackson's default string-length cap (20M chars) to fit local regulation document
                .streamReadConstraints(StreamReadConstraints.builder().maxStringLength(30_000_000).build())
                .build());
    }

    public DocumentRoot loadDocument(String filePath) throws IOException {
        Resource resource = filePath.contains(":") ? resourceLoader.getResource(filePath) : new FileSystemResource(filePath);
        if (!resource.exists()) {
            throw new IllegalArgumentException("Local regulations file not found at: " + filePath);
        }

        try (InputStream in = resource.getInputStream()) {
            return objectMapper.readValue(in, DocumentRoot.class);
        }
    }

    public TreeProcessingResult processTree(DocumentNode rootNode) {
        AtomicInteger idCounter = new AtomicInteger(1);
        Map<DocumentNode, Integer> nodeIds = new IdentityHashMap<>();
        Map<DocumentNode, List<Integer>> nodeChildIds = new IdentityHashMap<>();

        assignNodeIdsRecursively(rootNode, idCounter, nodeIds, nodeChildIds);

        return new TreeProcessingResult(nodeIds, nodeChildIds);
    }

    private int assignNodeIdsRecursively(DocumentNode node, AtomicInteger idCounter,
        Map<DocumentNode, Integer> nodeIds,
        Map<DocumentNode, List<Integer>> nodeChildIds) {
        int nodeId = idCounter.getAndIncrement();
        nodeIds.put(node, nodeId);

        List<Integer> childIds = node.children().stream()
            .map(child -> assignNodeIdsRecursively(child, idCounter, nodeIds, nodeChildIds))
            .toList();

        nodeChildIds.put(node, childIds);
        return nodeId;
    }

    public record TreeProcessingResult(
        Map<DocumentNode, Integer> nodeIds,
        Map<DocumentNode, List<Integer>> nodeChildIds
    ) {

    }
}
