package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.messages.model.RequestContext;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

@Component
class RequestContextRepository {

    private final Map<UUID, RequestContext> requestMetadataMap = new ConcurrentHashMap<>();

    public Optional<RequestContext> getRequestContext(UUID correlationId) {
        return Optional.ofNullable(requestMetadataMap.get(correlationId));
    }

    public void storeRequestContext(UUID correlationId, RequestContext value) {
        requestMetadataMap.put(correlationId, value);
    }
}
