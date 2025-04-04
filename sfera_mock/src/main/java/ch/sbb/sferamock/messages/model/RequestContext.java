package ch.sbb.sferamock.messages.model;

import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;

public record RequestContext(@NonNull TrainIdentification tid, @NonNull ClientId clientId, @NonNull Optional<UUID> incomingMessageId) {

    private static final int MINIMAL_TOPIC_ELEMENTS = 6;

    public RequestContext(@NonNull TrainIdentification tid, @NonNull ClientId clientId) {
        this(tid, clientId, Optional.empty());
    }

    public static RequestContext fromTopic(String topic) {
        return RequestContext.fromTopic(topic, Optional.empty());
    }

    public static RequestContext fromTopic(String topic, Optional<UUID> incomingMessageId) {
        String[] elements = topic.split("/");
        var length = elements.length;
        if (length < MINIMAL_TOPIC_ELEMENTS) {
            throw new IllegalArgumentException("The topic must contain at least 6 elements. Topic name: " + topic);
        }

        var tid = TrainIdentification.fromString(elements[length - 2], elements[length - 3]);

        return new RequestContext(tid, new ClientId(elements[length - 1]), incomingMessageId);
    }
}
